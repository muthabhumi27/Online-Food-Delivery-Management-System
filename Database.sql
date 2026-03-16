-- ============================================================
--  FoodRush Pune — Complete Database Setup
--  History  : February 2026
--  This Month: March 2026 (for Q4 active customers & Q5 delivery)
--  Run: mysql -u root -p < database.sql
-- ============================================================

DROP DATABASE IF EXISTS food_delivery_db;
CREATE DATABASE food_delivery_db;
USE food_delivery_db;

-- ─────────────────────────────────────────
--  TABLES
-- ─────────────────────────────────────────

CREATE TABLE Customer (
    CustomerID    INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName  VARCHAR(100) NOT NULL,
    CustomerEmail VARCHAR(100),
    Phone         VARCHAR(15) UNIQUE
);

CREATE TABLE Address (
    AddressID  INT AUTO_INCREMENT PRIMARY KEY,
    Street     VARCHAR(200),
    City       VARCHAR(100),
    Pincode    VARCHAR(10),
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Restaurant (
    RestaurantID   INT AUTO_INCREMENT PRIMARY KEY,
    RestaurantName VARCHAR(100) NOT NULL,
    Location       VARCHAR(200),
    ContactNumber  VARCHAR(15)
);

CREATE TABLE FoodItem (
    FoodItemID   INT AUTO_INCREMENT PRIMARY KEY,
    Name         VARCHAR(100) NOT NULL,
    Price        DECIMAL(10,2),
    Availability BOOLEAN DEFAULT TRUE,
    RestaurantID INT,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

CREATE TABLE `Order` (
    OrderID      INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate    DATE NOT NULL,
    TotalAmount  DECIMAL(10,2) DEFAULT 0,
    OrderStatus  ENUM('Placed','Preparing','Out for Delivery','Delivered','Cancelled') DEFAULT 'Placed',
    CustomerID   INT,
    RestaurantID INT,
    FOREIGN KEY (CustomerID)   REFERENCES Customer(CustomerID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

CREATE TABLE OrderItem (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID     INT,
    FoodItemID  INT,
    Quantity    INT NOT NULL,
    ItemPrice   DECIMAL(10,2),
    FOREIGN KEY (OrderID)    REFERENCES `Order`(OrderID),
    FOREIGN KEY (FoodItemID) REFERENCES FoodItem(FoodItemID)
);

CREATE TABLE Payment (
    PaymentID     INT AUTO_INCREMENT PRIMARY KEY,
    PaymentMethod ENUM('UPI','Card','Cash','Wallet') DEFAULT 'UPI',
    PaymentStatus ENUM('Paid','Pending','Failed')    DEFAULT 'Pending',
    PaymentDate   DATE,
    OrderID       INT,
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID)
);

CREATE TABLE DeliveryPartner (
    PartnerID   INT AUTO_INCREMENT PRIMARY KEY,
    Name        VARCHAR(100) NOT NULL,
    Phone       VARCHAR(15),
    VehicleType ENUM('Bike','Scooter','Cycle') DEFAULT 'Bike',
    OrderID     INT,
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID)
);

CREATE TABLE Review (
    ReviewID     INT AUTO_INCREMENT PRIMARY KEY,
    Rating       DECIMAL(2,1) CHECK (Rating BETWEEN 1 AND 5),
    Comment      TEXT,
    ReviewDate   DATE,
    CustomerID   INT,
    RestaurantID INT,
    FOREIGN KEY (CustomerID)   REFERENCES Customer(CustomerID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

-- ─────────────────────────────────────────
--  CUSTOMERS
-- ─────────────────────────────────────────
INSERT INTO Customer (CustomerName, CustomerEmail, Phone) VALUES
('Aarav Sharma',   'aarav@gmail.com',  '9876501001'),
('Priya Desai',    'priya@gmail.com',  '9876501002'),
('Rohan Kulkarni', 'rohan@gmail.com',  '9876501003'),
('Sneha Joshi',    'sneha@gmail.com',  '9876501004'),
('Arjun Mehta',    'arjun@gmail.com',  '9876501005');

-- ─────────────────────────────────────────
--  ADDRESSES
-- ─────────────────────────────────────────
INSERT INTO Address (Street, City, Pincode, CustomerID) VALUES
('301 Sunrise Apts, FC Road',        'Pune', '411004', 1),
('B-12 Koregaon Park',               'Pune', '411001', 2),
('22 Deccan Gymkhana',               'Pune', '411004', 3),
('45 Baner Road',                    'Pune', '411045', 4),
('8A Aundh ITI Road',                'Pune', '411007', 5),
('7th Floor, Rajiv Gandhi IT Park',  'Pune', '411057', 1),
('Hostel Block C, Symbiosis',        'Pune', '411004', 3),
('Infosys Campus Gate 4, Hinjewadi', 'Pune', '411057', 5);

-- ─────────────────────────────────────────
--  RESTAURANTS
-- ─────────────────────────────────────────
INSERT INTO Restaurant (RestaurantName, Location, ContactNumber) VALUES
('Vohuman Café',          'Sassoon Road, Camp, Pune',     '020-26361788'),
('Kayani Bakery',         'East Street, Camp, Pune',      '020-26362989'),
('Malaka Spice',          'Lane 5, Koregaon Park, Pune',  '020-26135682'),
('Rangla Punjab',         'Pashan, Pune',                 '9960001234'),
('The Belgian Waffle Co.','FC Road, Shivajinagar, Pune',  '9922334455'),
('Café Goodluck',         'Deccan Gymkhana, Pune',        '020-25672761');

-- ─────────────────────────────────────────
--  FOOD ITEMS
-- ─────────────────────────────────────────
INSERT INTO FoodItem (Name, Price, Availability, RestaurantID) VALUES
-- Vohuman Café (IDs 1–7)
('Bun Maska',            40,  1, 1),
('Brun Maska',           45,  1, 1),
('Egg Half Fry',         55,  1, 1),
('Chicken Sandwich',    120,  1, 1),
('Special Irani Chai',   30,  1, 1),
('Cold Coffee',          70,  1, 1),
('Lassi',                60,  1, 1),
-- Kayani Bakery (IDs 8–13)
('Shrewsbury Biscuits', 180,  1, 2),
('Mawa Cake',            65,  1, 2),
('Khari Biscuit',        90,  1, 2),
('Wine Biscuits',       120,  1, 2),
('Cream Roll',           55,  1, 2),
('Plum Cake',            85,  1, 2),
-- Malaka Spice (IDs 14–19)
('Thai Green Curry',    380,  1, 3),
('Pad Thai Noodles',    320,  1, 3),
('Tom Yum Soup',        240,  1, 3),
('Sushi Platter 8pcs',  520,  1, 3),
('Kimchi Fried Rice',   290,  1, 3),
('Ramen Bowl',          340,  1, 3),
-- Rangla Punjab (IDs 20–26)
('Dal Makhani',         220,  1, 4),
('Paneer Butter Masala',280,  1, 4),
('Sarson Ka Saag',      240,  1, 4),
('Tandoori Roti',        35,  1, 4),
('Butter Naan',          55,  1, 4),
('Chicken Biryani',     320,  1, 4),
('Seekh Kebab 4pcs',    280,  0, 4),  -- unavailable → Q3
-- Belgian Waffle Co. (IDs 27–32)
('Classic Choco Waffle',180,  1, 5),
('Strawberry Sensation',200,  1, 5),
('Nutella Overload',    220,  1, 5),
('Lotus Biscoff',       240,  1, 5),
('Oreo Milkshake',      150,  1, 5),
('Mango Smoothie',      130,  1, 5),
-- Café Goodluck (IDs 33–38)
('Chicken Berry Pulao', 340,  1, 6),
('Mutton Dhansak',      380,  1, 6),
('Akuri on Toast',      160,  1, 6),
('Cheese Omelette',     120,  1, 6),
('Irani Chai',           30,  0, 6),  -- unavailable → Q3
('Caramel Custard',      80,  1, 6);

-- ─────────────────────────────────────────
--  ORDERS
--
--  Orders 1–25  : February 2026 history
--                 Spread across all 7 weekdays for Q2 (peak days)
--                 2026-02-02 = Monday
--                 2026-02-03 = Tuesday
--                 2026-02-04 = Wednesday
--                 2026-02-06 = Friday
--                 2026-02-07 = Saturday
--                 2026-02-08 = Sunday
--
--  Orders 26–40 : March 2026 — current month
--                 Uses DATE_SUB(CURDATE()) so always "this month"
--                 Powers Q4 (active customers) & Q5 (delivery partners)
-- ─────────────────────────────────────────
INSERT INTO `Order` (OrderDate, OrderStatus, CustomerID, RestaurantID) VALUES
-- ── February 2026 history ──
('2026-02-02', 'Delivered', 3, 3),   -- 1  Monday
('2026-02-03', 'Delivered', 5, 1),   -- 2  Tuesday
('2026-02-04', 'Delivered', 1, 2),   -- 3  Wednesday
('2026-02-06', 'Delivered', 3, 6),   -- 4  Friday
('2026-02-07', 'Delivered', 5, 3),   -- 5  Saturday
('2026-02-08', 'Delivered', 3, 3),   -- 6  Sunday
('2026-02-09', 'Delivered', 1, 1),   -- 7  Monday
('2026-02-10', 'Delivered', 2, 4),   -- 8  Tuesday
('2026-02-11', 'Delivered', 3, 5),   -- 9  Wednesday
('2026-02-13', 'Delivered', 5, 6),   -- 10 Friday
('2026-02-14', 'Delivered', 4, 3),   -- 11 Saturday
('2026-02-15', 'Delivered', 3, 1),   -- 12 Sunday
('2026-02-16', 'Delivered', 1, 3),   -- 13 Monday
('2026-02-17', 'Delivered', 5, 2),   -- 14 Tuesday
('2026-02-18', 'Delivered', 2, 6),   -- 15 Wednesday
('2026-02-20', 'Delivered', 3, 3),   -- 16 Friday
('2026-02-21', 'Delivered', 4, 4),   -- 17 Saturday
('2026-02-22', 'Delivered', 1, 5),   -- 18 Sunday
('2026-02-23', 'Delivered', 5, 3),   -- 19 Monday
('2026-02-24', 'Cancelled', 2, 1),   -- 20 Tuesday  (cancelled → excluded Q2)
('2026-02-25', 'Delivered', 3, 6),   -- 21 Wednesday
('2026-02-26', 'Delivered', 1, 2),   -- 22 Thursday
('2026-02-27', 'Delivered', 5, 3),   -- 23 Friday
('2026-02-14', 'Placed',    2, 4),   -- 24 unavailable item, no payment → Q3
('2026-02-20', 'Placed',    4, 6),   -- 25 unavailable item, no payment → Q3
-- ── March 2026 — current month (Q4 active customers + Q5 delivery) ──
-- Rohan (CustomerID 3) — most active, 5 orders
(DATE_SUB(CURDATE(), INTERVAL 2  DAY), 'Delivered', 3, 3),  -- 26
(DATE_SUB(CURDATE(), INTERVAL 5  DAY), 'Delivered', 3, 1),  -- 27
(DATE_SUB(CURDATE(), INTERVAL 8  DAY), 'Delivered', 3, 6),  -- 28
(DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Delivered', 3, 3),  -- 29
(DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Delivered', 3, 2),  -- 30
-- Arjun (CustomerID 5) — 4 orders
(DATE_SUB(CURDATE(), INTERVAL 3  DAY), 'Delivered', 5, 3),  -- 31
(DATE_SUB(CURDATE(), INTERVAL 7  DAY), 'Delivered', 5, 6),  -- 32
(DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered', 5, 1),  -- 33
(DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'Delivered', 5, 3),  -- 34
-- Aarav (CustomerID 1) — 3 orders
(DATE_SUB(CURDATE(), INTERVAL 4  DAY), 'Delivered', 1, 2),  -- 35
(DATE_SUB(CURDATE(), INTERVAL 9  DAY), 'Delivered', 1, 3),  -- 36
(DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Delivered', 1, 6),  -- 37
-- Priya (CustomerID 2) — 2 orders
(DATE_SUB(CURDATE(), INTERVAL 6  DAY), 'Delivered', 2, 4),  -- 38
(DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'Delivered', 2, 5),  -- 39
-- Sneha (CustomerID 4) — 1 order
(DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Delivered', 4, 1);  -- 40

-- ─────────────────────────────────────────
--  ORDER ITEMS
-- ─────────────────────────────────────────
INSERT INTO OrderItem (OrderID, FoodItemID, Quantity, ItemPrice) VALUES
-- February history
(1,  14, 4, 380), (1,  15, 3, 320),
(2,   1, 3,  40), (2,   5, 4,  30),
(3,   8, 3, 180), (3,   9, 2,  65),
(4,  33, 2, 340), (4,  36, 3,  80),
(5,  14, 4, 380), (5,  16, 2, 240),
(6,  14, 5, 380), (6,  15, 3, 320),
(7,   1, 4,  40), (7,   5, 5,  30),
(8,  20, 2, 220), (8,  26, 1, 320),
(9,  27, 3, 180), (9,  31, 2, 150),
(10, 33, 3, 340), (10, 37, 2,  80),
(11, 14, 4, 380), (11, 18, 2, 290),
(12,  1, 3,  40), (12,  5, 4,  30),
(13, 14, 3, 380), (13, 17, 2, 520),
(14,  8, 2, 180), (14, 12, 3,  55),
(15, 33, 2, 340), (15, 35, 3, 160),
(16, 14, 5, 380), (16, 15, 4, 320),
(17, 20, 2, 220), (17, 24, 3,  35),
(18, 27, 2, 180), (18, 30, 2, 240),
(19, 14, 4, 380), (19, 18, 3, 290),
(20,  1, 2,  40), (20,  6, 1,  70),  -- cancelled order
(21, 33, 3, 340), (21, 34, 2, 380),
(22,  8, 3, 180), (22, 10, 2,  90),
(23, 14, 4, 380), (23, 15, 3, 320),
(24, 27, 2, 280),  -- Seekh Kebab unavailable → Q3
(25, 37, 1,  30),  -- Irani Chai unavailable  → Q3
-- March 2026 current month
(26, 14, 3, 380), (26, 15, 2, 320),
(27,  1, 4,  40), (27,  5, 3,  30),
(28, 33, 2, 340), (28, 35, 2, 160),
(29, 14, 4, 380), (29, 18, 2, 290),
(30,  8, 3, 180), (30,  9, 2,  65),
(31, 14, 3, 380), (31, 16, 2, 240),
(32, 33, 2, 340), (32, 36, 2,  80),
(33,  1, 3,  40), (33,  5, 4,  30),
(34, 14, 4, 380), (34, 15, 3, 320),
(35,  8, 2, 180), (35, 13, 1,  85),
(36, 14, 2, 380), (36, 16, 1, 240),
(37, 33, 2, 340), (37, 37, 2,  80),
(38, 20, 2, 220), (38, 26, 1, 320),
(39, 27, 2, 180), (39, 31, 1, 150),
(40,  1, 2,  40), (40,  5, 3,  30);

-- ─────────────────────────────────────────
--  PAYMENTS
--  Orders 24 & 25 → NO payment row (NOT EXISTS fires for Q3)
--  Cash = Pending, rest = Paid
-- ─────────────────────────────────────────
INSERT INTO Payment (PaymentMethod, PaymentStatus, PaymentDate, OrderID) VALUES
('UPI',    'Paid',    '2026-02-02',  1),
('Card',   'Paid',    '2026-02-03',  2),
('UPI',    'Paid',    '2026-02-04',  3),
('Wallet', 'Paid',    '2026-02-06',  4),
('UPI',    'Paid',    '2026-02-07',  5),
('UPI',    'Paid',    '2026-02-08',  6),
('Card',   'Paid',    '2026-02-09',  7),
('Cash',   'Pending', '2026-02-10',  8),
('UPI',    'Paid',    '2026-02-11',  9),
('UPI',    'Paid',    '2026-02-13', 10),
('Card',   'Paid',    '2026-02-14', 11),
('UPI',    'Paid',    '2026-02-15', 12),
('Wallet', 'Paid',    '2026-02-16', 13),
('UPI',    'Paid',    '2026-02-17', 14),
('UPI',    'Paid',    '2026-02-18', 15),
('Card',   'Paid',    '2026-02-20', 16),
('Cash',   'Pending', '2026-02-21', 17),
('UPI',    'Paid',    '2026-02-22', 18),
('UPI',    'Paid',    '2026-02-23', 19),
('UPI',    'Failed',  '2026-02-24', 20),
('Wallet', 'Paid',    '2026-02-25', 21),
('UPI',    'Paid',    '2026-02-26', 22),
('Card',   'Paid',    '2026-02-27', 23),
-- Orders 24 & 25 → intentionally NO payment row
-- March 2026 payments
('UPI',    'Paid',    CURDATE(), 26),
('UPI',    'Paid',    CURDATE(), 27),
('Card',   'Paid',    CURDATE(), 28),
('UPI',    'Paid',    CURDATE(), 29),
('Wallet', 'Paid',    CURDATE(), 30),
('UPI',    'Paid',    CURDATE(), 31),
('Card',   'Paid',    CURDATE(), 32),
('UPI',    'Paid',    CURDATE(), 33),
('UPI',    'Paid',    CURDATE(), 34),
('Cash',   'Pending', CURDATE(), 35),
('UPI',    'Paid',    CURDATE(), 36),
('Wallet', 'Paid',    CURDATE(), 37),
('UPI',    'Paid',    CURDATE(), 38),
('Card',   'Paid',    CURDATE(), 39),
('Cash',   'Pending', CURDATE(), 40);

-- ─────────────────────────────────────────
--  DELIVERY PARTNERS
--  All assigned to March 2026 orders so Q5 returns live data
--  Sanjay = 3 deliveries (clear #1)
-- ─────────────────────────────────────────
INSERT INTO DeliveryPartner (Name, Phone, VehicleType, OrderID) VALUES
('Sanjay Patil',  '9876541001', 'Bike',    26),
('Rahul Shinde',  '9876541002', 'Scooter', 27),
('Amit Waghmare', '9876541003', 'Bike',    28),
('Ganesh Jadhav', '9876541004', 'Scooter', 29),
('Vijay Kale',    '9876541005', 'Bike',    30),
('Sanjay Patil',  '9876541001', 'Bike',    31),
('Rahul Shinde',  '9876541002', 'Scooter', 32),
('Amit Waghmare', '9876541003', 'Bike',    33),
('Sanjay Patil',  '9876541001', 'Bike',    34),
('Ganesh Jadhav', '9876541004', 'Scooter', 35),
('Rahul Shinde',  '9876541002', 'Scooter', 36),
('Vijay Kale',    '9876541005', 'Bike',    37),
('Amit Waghmare', '9876541003', 'Bike',    38),
('Ganesh Jadhav', '9876541004', 'Scooter', 39),
('Vijay Kale',    '9876541005', 'Bike',    40);

-- ─────────────────────────────────────────
--  REVIEWS
--  6+ per restaurant so HAVING COUNT > 5 passes in Q1
-- ─────────────────────────────────────────
INSERT INTO Review (Rating, Comment, ReviewDate, CustomerID, RestaurantID) VALUES
-- Vohuman Café (7 reviews)
(5.0, 'Best Irani chai in Pune!',         '2026-02-07', 1, 1),
(4.5, 'Bun Maska every morning',          '2026-02-09', 2, 1),
(4.8, 'Authentic old Pune vibe',          '2026-02-12', 3, 1),
(4.7, 'Classic breakfast spot',           '2026-02-15', 5, 1),
(4.6, 'Simple and consistently great',   '2026-02-18', 4, 1),
(5.0, 'Best chai, period.',               '2026-02-22', 1, 1),
(4.9, 'Never disappoints',               '2026-02-25', 3, 1),
-- Kayani Bakery (7 reviews)
(4.9, 'Shrewsbury biscuits legendary',   '2026-02-03', 2, 2),
(5.0, 'Mawa cake is divine',             '2026-02-08', 4, 2),
(4.8, 'Kayani never disappoints',        '2026-02-13', 3, 2),
(4.7, 'Worth the queue every time',      '2026-02-17', 1, 2),
(4.6, 'Cream rolls fresh daily',         '2026-02-20', 5, 2),
(4.9, 'Iconic Pune institution',         '2026-02-23', 2, 2),
(4.8, 'Plum cake was rich',              '2026-02-26', 4, 2),
-- Malaka Spice (9 reviews — highest rated, drives Q1)
(5.0, 'Pad Thai absolutely perfect',     '2026-02-02', 3, 3),
(4.9, 'Tom Yum soup incredible',         '2026-02-05', 5, 3),
(4.8, 'Sushi was super fresh',           '2026-02-07', 1, 3),
(4.7, 'Amazing KP ambiance',             '2026-02-11', 2, 3),
(4.9, 'Best Pan-Asian in Pune',          '2026-02-14', 4, 3),
(4.8, 'Kimchi fried rice addictive',     '2026-02-16', 3, 3),
(5.0, 'Thai green curry top notch',      '2026-02-19', 5, 3),
(4.9, 'Ramen bowl was comforting',       '2026-02-21', 1, 3),
(5.0, 'Best restaurant in Pune',         '2026-02-27', 3, 3),
-- Rangla Punjab (6 reviews)
(4.2, 'Dal Makhani very creamy',         '2026-02-04', 4, 4),
(4.3, 'Good dhaba vibes',                '2026-02-10', 1, 4),
(4.0, 'Value for money',                 '2026-02-13', 5, 4),
(4.1, 'Chicken biryani was good',        '2026-02-17', 2, 4),
(4.4, 'Butter naan was fluffy',          '2026-02-21', 3, 4),
(4.2, 'Will visit again',               '2026-02-25', 4, 4),
-- Belgian Waffle Co. (6 reviews)
(4.0, 'Nutella waffle was rich',         '2026-02-06', 5, 5),
(4.2, 'Worth every rupee',               '2026-02-10', 2, 5),
(4.3, 'Lotus Biscoff waffle amazing',    '2026-02-14', 1, 5),
(4.1, 'Oreo milkshake was thick',        '2026-02-18', 3, 5),
(4.0, 'Nice FC Road spot',               '2026-02-22', 4, 5),
(4.2, 'Great dessert place',             '2026-02-26', 5, 5),
-- Café Goodluck (8 reviews)
(4.8, 'Berry Pulao is iconic',           '2026-02-03', 1, 6),
(4.7, 'Mutton Dhansak wow',              '2026-02-06', 3, 6),
(4.6, 'Irani chai great as always',      '2026-02-09', 5, 6),
(4.9, 'Best Parsi food in the city',     '2026-02-13', 2, 6),
(5.0, 'Akuri on toast is perfect',       '2026-02-16', 4, 6),
(4.8, 'Always open, always good',        '2026-02-19', 1, 6),
(4.7, 'Cheese omelette was fluffy',      '2026-02-23', 3, 6),
(4.9, 'Historic place, great food',      '2026-02-27', 5, 6);

-- ─────────────────────────────────────────
--  VIEW for Q4
-- ─────────────────────────────────────────
CREATE OR REPLACE VIEW CustomerOrderSummary AS
SELECT c.CustomerID,
       c.CustomerName,
       COUNT(o.OrderID)                AS TotalOrders,
       SUM(oi.Quantity * oi.ItemPrice) AS TotalSpent,
       MAX(o.OrderDate)                AS LastOrderDate
FROM Customer c
JOIN `Order`   o  ON c.CustomerID = o.CustomerID
JOIN OrderItem oi ON o.OrderID    = oi.OrderID
GROUP BY c.CustomerID, c.CustomerName;

-- ─────────────────────────────────────────
--  VERIFY ALL 5 QUERIES
-- ─────────────────────────────────────────

SELECT '✅ Database ready!' AS Status;

SELECT '═══ Q1: Top 3 Restaurants by Avg Rating & Revenue ═══' AS '';
SELECT r.RestaurantName,
       ROUND(AVG(rev.Rating), 1)             AS AvgRating,
       SUM(oi.Quantity * oi.ItemPrice)        AS TotalRevenue
FROM Restaurant r
JOIN Review    rev ON r.RestaurantID = rev.RestaurantID
JOIN `Order`   o   ON r.RestaurantID = o.RestaurantID
JOIN OrderItem oi  ON o.OrderID      = oi.OrderID
GROUP BY r.RestaurantID, r.RestaurantName
HAVING COUNT(o.OrderID) > 5
ORDER BY AvgRating DESC, TotalRevenue DESC
LIMIT 3;

SELECT '═══ Q2: Peak Ordering Days ═══' AS '';
SELECT DAYNAME(o.OrderDate)            AS DayOfWeek,
       COUNT(o.OrderID)                AS TotalOrders,
       SUM(oi.Quantity * oi.ItemPrice) AS Revenue
FROM `Order` o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
WHERE o.OrderStatus != 'Cancelled'
GROUP BY DAYNAME(o.OrderDate), DAYOFWEEK(o.OrderDate)
ORDER BY DAYOFWEEK(o.OrderDate);

SELECT '═══ Q3: Top 5 Most Popular Food Items ═══' AS '';
SELECT fi.Name                    AS FoodItem,
       r.RestaurantName,
       SUM(oi.Quantity)           AS TotalOrdered,
       COUNT(DISTINCT oi.OrderID) AS OrderedInOrders
FROM FoodItem fi
JOIN OrderItem oi  ON fi.FoodItemID   = oi.FoodItemID
JOIN Restaurant r  ON fi.RestaurantID = r.RestaurantID
GROUP BY fi.FoodItemID, fi.Name, r.RestaurantName
ORDER BY TotalOrdered DESC
LIMIT 5;

SELECT '═══ Q4: Most Active Customers This Month (March 2026) ═══' AS '';
SELECT c.CustomerName,
       COUNT(o.OrderID)                AS OrdersThisMonth,
       SUM(oi.Quantity * oi.ItemPrice) AS MonthlySpend,
       MAX(o.OrderDate)                AS LastOrderDate
FROM CustomerOrderSummary cos
JOIN Customer  c  ON cos.CustomerID = c.CustomerID
JOIN `Order`   o  ON c.CustomerID   = o.CustomerID
JOIN OrderItem oi ON o.OrderID      = oi.OrderID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
  AND o.OrderStatus != 'Cancelled'
GROUP BY c.CustomerID, c.CustomerName
ORDER BY OrdersThisMonth DESC, MonthlySpend DESC;

SELECT '═══ Q5: Top Delivery Partners This Month (March 2026) ═══' AS '';
SELECT dp.Name          AS DeliveryManName,
       dp.VehicleType,
       COUNT(o.OrderID) AS Deliveries
FROM DeliveryPartner dp
JOIN `Order` o ON dp.OrderID = o.OrderID
WHERE o.OrderStatus = 'Delivered'
  AND o.OrderDate  >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY dp.PartnerID, dp.Name, dp.VehicleType
ORDER BY Deliveries DESC
LIMIT 5;