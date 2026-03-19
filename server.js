const express = require('express');
const mysql   = require('mysql2/promise');
const path    = require('path');
const app     = express();

app.use(express.json());
app.use(express.static(__dirname));

// ── DB CONFIG ─────────────────────────────────────────────────────────────────
const DB = {
  host:     'localhost',
  user:     'root',
  password: 'root',          // ← change to your MySQL root password
  database: 'food_delivery_db',
  waitForConnections: true,
  connectionLimit: 10,
};

let pool;
(async () => {
  try {
    pool = mysql.createPool(DB);
    await pool.query('SELECT 1');
    console.log('✅ MySQL connected — food_delivery_db');
  } catch(e) {
    console.error('❌ MySQL connection failed:', e.message);
    console.log('   Server still running — analytics will use demo data.');
  }
})();

// ── HELPER ────────────────────────────────────────────────────────────────────
async function query(sql, params = []) {
  const [rows] = await pool.query(sql, params);
  return rows;
}

// ── SERVE index.html ──────────────────────────────────────────────────────────
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'index.html')));

// ═══════════════════════════════════════════════════════════════════════════════
//  ANALYTICS QUERIES
// ═══════════════════════════════════════════════════════════════════════════════

// Q1: Top 5 Restaurants by Avg Rating & Revenue
app.get('/api/q1-top-restaurants', async (req, res) => {
  try {
    const rows = await query(`
      SELECT r.RestaurantName,
             ROUND(AVG(rev.Rating), 1)        AS AvgRating,
             COUNT(DISTINCT rev.ReviewID)      AS TotalReviews,
             SUM(oi.Quantity * oi.ItemPrice)   AS TotalRevenue
      FROM Restaurant r
      JOIN Review    rev ON r.RestaurantID = rev.RestaurantID
      JOIN \`Order\`  o   ON r.RestaurantID = o.RestaurantID AND o.OrderStatus = 'Delivered'
      JOIN OrderItem oi  ON o.OrderID      = oi.OrderID
      GROUP BY r.RestaurantID, r.RestaurantName
      ORDER BY AvgRating DESC, TotalRevenue DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// Q2: Peak Day Per Restaurant — exactly ONE row per restaurant, no ties
app.get('/api/q2-peak-days', async (req, res) => {
  try {
    const rows = await query(`
      SELECT r.RestaurantName,
             DAYNAME(o.OrderDate)        AS PeakDay,
             COUNT(DISTINCT o.OrderID)   AS TotalOrders
      FROM Restaurant r
      JOIN \`Order\` o ON r.RestaurantID = o.RestaurantID
                      AND o.OrderStatus = 'Delivered'
      GROUP BY r.RestaurantID, r.RestaurantName, DAYNAME(o.OrderDate)
      HAVING COUNT(DISTINCT o.OrderID) = (
          SELECT COUNT(DISTINCT o2.OrderID)
          FROM \`Order\` o2
          WHERE o2.RestaurantID = r.RestaurantID
            AND o2.OrderStatus  = 'Delivered'
          GROUP BY DAYNAME(o2.OrderDate)
          ORDER BY COUNT(DISTINCT o2.OrderID) DESC
          LIMIT 1
      )
      ORDER BY r.RestaurantName
    `);
    res.json(rows);
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// Q3: Top 5 Most Ordered Food Items
app.get('/api/q3-popular-items', async (req, res) => {
  try {
    const rows = await query(`
      SELECT fi.Name              AS FoodItem,
             r.RestaurantName,
             SUM(oi.Quantity)     AS TotalQtySold,
             COUNT(DISTINCT o.OrderID) AS AppearedInOrders,
             fi.Price             AS UnitPrice,
             SUM(oi.Quantity) * fi.Price AS TotalRevenue
      FROM FoodItem fi
      JOIN OrderItem oi ON fi.FoodItemID   = oi.FoodItemID
      JOIN \`Order\`  o  ON oi.OrderID      = o.OrderID AND o.OrderStatus = 'Delivered'
      JOIN Restaurant r ON fi.RestaurantID = r.RestaurantID
      WHERE fi.Availability = 1
      GROUP BY fi.FoodItemID, fi.Name, r.RestaurantName, fi.Price
      ORDER BY TotalQtySold DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// Q4: Most Active Customers — February 2026
app.get('/api/q4-active-customers', async (req, res) => {
  try {
    const rows = await query(`
      SELECT c.CustomerName,
             COUNT(DISTINCT o.OrderID)                  AS OrdersInFeb,
             SUM(oi.Quantity * oi.ItemPrice)            AS TotalSpentFeb,
             DATE_FORMAT(MAX(o.OrderDate), '%d %b %Y')  AS LastOrderDate
      FROM Customer c
      JOIN \`Order\`  o  ON c.CustomerID = o.CustomerID
      JOIN OrderItem oi ON o.OrderID    = oi.OrderID
      WHERE o.OrderDate BETWEEN '2026-02-01' AND '2026-02-28'
        AND o.OrderStatus = 'Delivered'
      GROUP BY c.CustomerID, c.CustomerName
      ORDER BY OrdersInFeb DESC, TotalSpentFeb DESC
      LIMIT 10
    `);
    res.json(rows);
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// Q5: Top Delivery Partners (last 30 days)
app.get('/api/q5-top-delivery', async (req, res) => {
  try {
    const rows = await query(`
      SELECT dp.Name          AS DeliveryPartner,
             dp.VehicleType,
             COUNT(dp.OrderID) AS TotalDeliveries
      FROM DeliveryPartner dp
      JOIN \`Order\` o ON dp.OrderID = o.OrderID
      WHERE o.OrderStatus = 'Delivered'
        AND o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY dp.Name, dp.VehicleType
      ORDER BY TotalDeliveries DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════════════════════
//  ORDER PLACEMENT
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/place-order', async (req, res) => {
  const { customerId, restaurantId, orderDate, paymentMethod, cart } = req.body;
  if (!customerId || !restaurantId || !cart?.length) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const totalAmount = cart.reduce((s, i) => s + i.qty * i.price, 0);
    const [orderResult] = await conn.query(
      `INSERT INTO \`Order\` (OrderDate, TotalAmount, OrderStatus, CustomerID, RestaurantID)
       VALUES (?, ?, 'Delivered', ?, ?)`,
      [orderDate || new Date().toISOString().split('T')[0], totalAmount, customerId, restaurantId]
    );
    const orderId = orderResult.insertId;
    for (const item of cart) {
      await conn.query(
        `INSERT INTO OrderItem (OrderID, FoodItemID, Quantity, ItemPrice) VALUES (?, ?, ?, ?)`,
        [orderId, item.id, item.qty, item.price]
      );
    }
    const payStatus = paymentMethod === 'Cash' ? 'Pending' : 'Paid';
    await conn.query(
      `INSERT INTO Payment (PaymentMethod, PaymentStatus, PaymentDate, OrderID) VALUES (?, ?, ?, ?)`,
      [paymentMethod || 'UPI', payStatus, orderDate || new Date().toISOString().split('T')[0], orderId]
    );
    await conn.commit();
    res.json({ success: true, orderId });
  } catch(e) {
    await conn.rollback();
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//  CUSTOMER LOGIN / SIGNUP
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/customer/login', async (req, res) => {
  const { phone } = req.body;
  try {
    const rows = await query('SELECT * FROM Customer WHERE Phone = ?', [phone]);
    if (rows.length) res.json({ found: true,  customer: rows[0] });
    else             res.json({ found: false });
  } catch(e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/customer/signup', async (req, res) => {
  const { name, phone, email } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO Customer (CustomerName, CustomerEmail, Phone) VALUES (?, ?, ?)',
      [name, phone, email || null]
    );
    res.json({ success: true, customerId: result.insertId });
  } catch(e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/address', async (req, res) => {
  const { customerId, flat, street, city, pin } = req.body;
  try {
    await pool.query(
      'INSERT INTO Address (Street, City, Pincode, CustomerID) VALUES (?, ?, ?, ?)',
      [`${flat}, ${street}`, city || 'Pune', pin, customerId]
    );
    res.json({ success: true });
  } catch(e) { res.status(500).json({ error: e.message }); }
});

// ── START ─────────────────────────────────────────────────────────────────────
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`\n🔥 FoodRush Pune running at http://localhost:${PORT}`);
  console.log(`   Open http://localhost:${PORT} in your browser\n`);
});