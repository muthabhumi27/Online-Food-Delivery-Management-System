const express = require('express');
const mysql   = require('mysql2');
const cors    = require('cors');
const path    = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

const db = mysql.createConnection({
    host:     'localhost',
    user:     'root',
    password: 'root',          // ← change if needed
    database: 'food_delivery_db'
});

db.connect(err => {
    if (err) { console.error('❌ DB connection failed:', err.message); console.log('⚠️  Demo mode active'); }
    else       console.log('✅ Connected to food_delivery_db');
});

const query = (sql, params = []) => new Promise((res, rej) =>
    db.query(sql, params, (err, rows) => err ? rej(err) : res(rows))
);

// ─────────────────────────────────────────
//  CUSTOMER LOGIN  (SELECT WHERE phone)
// ─────────────────────────────────────────
app.post('/api/customer/login', async (req, res) => {
    try {
        const rows = await query(
            `SELECT CustomerID as id, CustomerName as name, CustomerEmail as email, Phone as phone
             FROM Customer WHERE Phone = ? LIMIT 1`,
            [req.body.phone]
        );
        if (!rows.length) return res.json({ found: false });
        res.json({ found: true, customer: { ...rows[0], color: '#FF5722' } });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─────────────────────────────────────────
//  CUSTOMER SIGNUP  (INSERT INTO Customer)
// ─────────────────────────────────────────
app.post('/api/customer/signup', async (req, res) => {
    const { name, phone, email } = req.body;
    try {
        const exists = await query('SELECT CustomerID FROM Customer WHERE Phone = ?', [phone]);
        if (exists.length) return res.status(409).json({ error: 'Phone already registered' });
        const r = await query(
            'INSERT INTO Customer (CustomerName, CustomerEmail, Phone) VALUES (?, ?, ?)',
            [name, email || null, phone]
        );
        res.json({ success: true, customer: { id: r.insertId, name, phone, email: email || '', color: '#FF5722' } });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─────────────────────────────────────────
//  SAVE ADDRESS  (INSERT INTO Address)
// ─────────────────────────────────────────
app.post('/api/address', async (req, res) => {
    const { customerId, flat, street, city, pin } = req.body;
    try {
        await query(
            'INSERT INTO Address (Street, City, Pincode, CustomerID) VALUES (?, ?, ?, ?)',
            [flat + ', ' + street, city, pin, customerId]
        );
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─────────────────────────────────────────
//  FETCH MENU  (SELECT WHERE restaurantId)
// ─────────────────────────────────────────
app.get('/api/menu/:restaurantId', async (req, res) => {
    try {
        const rows = await query(
            'SELECT FoodItemID, Name, Price, Availability FROM FoodItem WHERE RestaurantID = ? AND Availability = 1',
            [req.params.restaurantId]
        );
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// ─────────────────────────────────────────
//  PLACE ORDER  (INSERT Order + OrderItem + Payment)
//  Now accepts paymentMethod from the frontend
// ─────────────────────────────────────────
app.post('/api/place-order', async (req, res) => {
    const { customerId, restaurantId, orderDate, cart, paymentMethod } = req.body;
    const method = ['UPI', 'Cash', 'Card', 'Wallet'].includes(paymentMethod) ? paymentMethod : 'UPI';
    try {
        // 1. Insert the order
        const orderRes = await query(
            "INSERT INTO `Order` (OrderDate, OrderStatus, CustomerID, RestaurantID) VALUES (?, 'Placed', ?, ?)",
            [orderDate, customerId, restaurantId]
        );
        const newOrderId = orderRes.insertId;

        // 2. Insert order items
        if (cart && cart.length) {
            const vals = cart.map(i => [newOrderId, i.id, i.qty, i.price]);
            await query('INSERT INTO OrderItem (OrderID, FoodItemID, Quantity, ItemPrice) VALUES ?', [vals]);
        }

        // 3. Insert payment record (PaymentStatus = 'Paid' for UPI/Card/Wallet, 'Pending' for Cash)
        const payStatus = method === 'Cash' ? 'Pending' : 'Paid';
        await query(
            "INSERT INTO Payment (PaymentMethod, PaymentStatus, PaymentDate, OrderID) VALUES (?, ?, CURDATE(), ?)",
            [method, payStatus, newOrderId]
        );

        res.json({ success: true, orderId: newOrderId });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// ══════════════════════════════════════════════════════════════════
//  5 ANALYTICS QUERIES  (exact SQL from project spec)
// ══════════════════════════════════════════════════════════════════

// Q1 — Top 3 Restaurants by Avg Rating & Revenue
//      Concepts: 4-table JOIN, AVG, SUM, GROUP BY, HAVING, ORDER BY, LIMIT
app.get('/api/q1-top-restaurants', async (req, res) => {
    const sql = `
        SELECT r.RestaurantName,
               ROUND(AVG(rev.Rating), 1)                       AS AvgRating,
               SUM(oi.Quantity * oi.ItemPrice)                  AS TotalRevenue
        FROM Restaurant r
        JOIN Review    rev ON r.RestaurantID = rev.RestaurantID
        JOIN \`Order\`  o   ON r.RestaurantID = o.RestaurantID
        JOIN OrderItem oi  ON o.OrderID      = oi.OrderID
        GROUP BY r.RestaurantID, r.RestaurantName
        HAVING COUNT(o.OrderID) > 5
        ORDER BY AvgRating DESC, TotalRevenue DESC
        LIMIT 5`;
    try { res.json(await query(sql)); } catch (e) { res.status(500).json({ error: e.message }); }
});

// Q2 — Restaurant vs Peak Ordering Days
//      Concepts: 3-table JOIN, DAYNAME, DAYOFWEEK, COUNT, SUM, GROUP BY, ORDER BY
app.get('/api/q2-peak-days', async (req, res) => {
    const sql = `
        SELECT r.RestaurantName,
               DAYNAME(o.OrderDate)             AS DayOfWeek,
               COUNT(o.OrderID)                 AS TotalOrders,
               SUM(oi.Quantity * oi.ItemPrice)  AS Revenue
        FROM Restaurant r
        JOIN \`Order\`   o  ON r.RestaurantID = o.RestaurantID
        JOIN OrderItem oi ON o.OrderID       = oi.OrderID
        WHERE o.OrderStatus != 'Cancelled'
        GROUP BY r.RestaurantID, r.RestaurantName,
                 DAYNAME(o.OrderDate), DAYOFWEEK(o.OrderDate)
        ORDER BY r.RestaurantName, DAYOFWEEK(o.OrderDate)`;
    try { res.json(await query(sql)); } catch (e) { res.status(500).json({ error: e.message }); }
});

// Q3 — Top 5 Most Popular Food Items by quantity ordered
//      Concepts: 3-table JOIN, SUM, COUNT DISTINCT, GROUP BY, ORDER BY, LIMIT
app.get('/api/q3-popular-items', async (req, res) => {
    const sql = `
        SELECT fi.Name                       AS FoodItem,
               r.RestaurantName,
               SUM(oi.Quantity)              AS TotalOrdered,
               COUNT(DISTINCT oi.OrderID)    AS OrderedInOrders
        FROM FoodItem fi
        JOIN OrderItem oi ON fi.FoodItemID   = oi.FoodItemID
        JOIN Restaurant r  ON fi.RestaurantID = r.RestaurantID
        GROUP BY fi.FoodItemID, fi.Name, r.RestaurantName
        ORDER BY TotalOrdered DESC
        LIMIT 5`;
    try { res.json(await query(sql)); } catch (e) { res.status(500).json({ error: e.message }); }
});

// Q4 — Most Active Customers in February 2026 (via VIEW)
//      Concepts: CREATE VIEW, DATE_FORMAT, COUNT, SUM, GROUP BY, ORDER BY
app.get('/api/q4-loyalty-segments', async (req, res) => {
    try {
        await query(`
            CREATE OR REPLACE VIEW CustomerOrderSummary AS
                SELECT c.CustomerID, c.CustomerName,
                       COUNT(o.OrderID)                AS TotalOrders,
                       SUM(oi.Quantity * oi.ItemPrice) AS TotalSpent,
                       MAX(o.OrderDate)                AS LastOrderDate
                FROM Customer c
                JOIN \`Order\`  o  ON c.CustomerID = o.CustomerID
                JOIN OrderItem oi ON o.OrderID    = oi.OrderID
                GROUP BY c.CustomerID, c.CustomerName`);
        const rows = await query(`
            SELECT c.CustomerName,
                   COUNT(o.OrderID)                              AS OrdersThisMonth,
                   SUM(oi.Quantity * oi.ItemPrice)               AS MonthlySpend,
                   DATE_FORMAT(MAX(o.OrderDate), '%d %b %Y')     AS LastOrderDate
            FROM CustomerOrderSummary cos
            JOIN Customer  c  ON cos.CustomerID = c.CustomerID
            JOIN \`Order\`  o  ON c.CustomerID  = o.CustomerID
            JOIN OrderItem oi ON o.OrderID      = oi.OrderID
            WHERE o.OrderDate >= '2026-02-01'
              AND o.OrderDate <  '2026-03-01'
              AND o.OrderStatus != 'Cancelled'
            GROUP BY c.CustomerID, c.CustomerName
            ORDER BY OrdersThisMonth DESC, MonthlySpend DESC`);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// Q5 — Top 5 Delivery Partners with most deliveries in last month
//      Concepts: DATE_SUB, CURDATE(), WHERE on date, GROUP BY, ORDER BY, LIMIT
app.get('/api/q5-top-delivery', async (req, res) => {
    const sql = `
        SELECT dp.Name AS DeliveryManName,
               COUNT(o.OrderID) AS Deliveries
        FROM DeliveryPartner dp
        JOIN \`Order\` o ON dp.OrderID = o.OrderID
        WHERE o.OrderStatus = 'Delivered'
          AND o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
        GROUP BY dp.PartnerID, dp.Name
        ORDER BY Deliveries DESC
        LIMIT 5`;
    try { res.json(await query(sql)); } catch (e) { res.status(500).json({ error: e.message }); }
});

// ══════════════════════════════════════════════════════════════════
//  ADVANCED ANALYTICS PAGE  (analytics.html endpoints)
// ══════════════════════════════════════════════════════════════════

// adv/q1 — same as Q1 but returns OrderCount too
app.get('/api/adv/q1', async (req, res) => {
    try {
        const rows = await query(`
            SELECT r.RestaurantName,
                   ROUND(AVG(rev.Rating), 2)              AS AvgRating,
                   SUM(oi.Quantity * oi.ItemPrice)         AS TotalRevenue,
                   COUNT(DISTINCT o.OrderID)               AS OrderCount
            FROM Restaurant r
            JOIN Review    rev ON r.RestaurantID = rev.RestaurantID
            JOIN \`Order\`  o   ON r.RestaurantID = o.RestaurantID
            JOIN OrderItem oi  ON o.OrderID      = oi.OrderID
            GROUP BY r.RestaurantID, r.RestaurantName
            HAVING COUNT(o.OrderID) > 5
            ORDER BY AvgRating DESC, TotalRevenue DESC
            LIMIT 5`);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// adv/q2 — restaurant vs peak days
app.get('/api/adv/q2', async (req, res) => {
    try {
        const rows = await query(`
            SELECT r.RestaurantName,
                   DAYNAME(o.OrderDate)             AS DayOfWeek,
                   COUNT(o.OrderID)                 AS TotalOrders,
                   SUM(oi.Quantity * oi.ItemPrice)  AS Revenue
            FROM Restaurant r
            JOIN \`Order\`   o  ON r.RestaurantID = o.RestaurantID
            JOIN OrderItem oi ON o.OrderID       = oi.OrderID
            WHERE o.OrderStatus != 'Cancelled'
            GROUP BY r.RestaurantID, r.RestaurantName,
                     DAYNAME(o.OrderDate), DAYOFWEEK(o.OrderDate)
            ORDER BY r.RestaurantName, DAYOFWEEK(o.OrderDate)`);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// adv/q3 — popular items (same query, no DISTINCT wrapper needed)
app.get('/api/adv/q3', async (req, res) => {
    try {
        const rows = await query(`
            SELECT fi.Name                       AS FoodItem,
                   r.RestaurantName,
                   SUM(oi.Quantity)              AS TotalOrdered,
                   COUNT(DISTINCT oi.OrderID)    AS OrderedInOrders
            FROM FoodItem fi
            JOIN OrderItem oi ON fi.FoodItemID   = oi.FoodItemID
            JOIN Restaurant r  ON fi.RestaurantID = r.RestaurantID
            GROUP BY fi.FoodItemID, fi.Name, r.RestaurantName
            ORDER BY TotalOrdered DESC
            LIMIT 5`);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// adv/q4 — most active customers in February 2026 from VIEW
app.get('/api/adv/q4', async (req, res) => {
    try {
        const rows = await query(`
            SELECT c.CustomerName,
                   COUNT(o.OrderID)                              AS OrdersThisMonth,
                   SUM(oi.Quantity * oi.ItemPrice)               AS MonthlySpend,
                   DATE_FORMAT(MAX(o.OrderDate), '%d %b %Y')     AS LastOrderDate
            FROM CustomerOrderSummary cos
            JOIN Customer  c  ON cos.CustomerID = c.CustomerID
            JOIN \`Order\`  o  ON c.CustomerID  = o.CustomerID
            JOIN OrderItem oi ON o.OrderID      = oi.OrderID
            WHERE o.OrderDate >= '2026-02-01'
              AND o.OrderDate <  '2026-03-01'
              AND o.OrderStatus != 'Cancelled'
            GROUP BY c.CustomerID, c.CustomerName
            ORDER BY OrdersThisMonth DESC, MonthlySpend DESC`);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// adv/q5
app.get('/api/adv/q5', async (req, res) => {
    try {
        const rows = await query(`
            SELECT dp.Name AS DeliveryManName, dp.VehicleType,
                   COUNT(o.OrderID) AS Deliveries
            FROM DeliveryPartner dp
            JOIN \`Order\` o ON dp.OrderID = o.OrderID
            WHERE o.OrderStatus = 'Delivered'
              AND o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
            GROUP BY dp.PartnerID, dp.Name, dp.VehicleType
            ORDER BY Deliveries DESC
            LIMIT 5`);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// Fallback — serve index.html for any unmatched route
app.use((req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(3000, () => {
    console.log('\n🚀 FoodRush running → http://localhost:3000');
    console.log('📊 Analytics: /api/q1-top-restaurants … /api/q5-top-delivery');
    console.log('📈 Adv Analytics: /api/adv/q1 … /api/adv/q5\n');
});