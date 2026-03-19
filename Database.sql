-- ============================================================
--  FoodRush Pune — Expanded Database
--  15 Customers · 10 Restaurants · 120+ Orders
--  Jan 2026 + Feb 2026 history · Mar 2026 current month
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
--  15 CUSTOMERS
-- ─────────────────────────────────────────
INSERT INTO Customer (CustomerName, CustomerEmail, Phone) VALUES
('Aarav Sharma',    'aarav@gmail.com',    '9876501001'),
('Priya Desai',     'priya@gmail.com',    '9876501002'),
('Rohan Kulkarni',  'rohan@gmail.com',    '9876501003'),
('Sneha Joshi',     'sneha@gmail.com',    '9876501004'),
('Arjun Mehta',     'arjun@gmail.com',    '9876501005'),
('Kavya Nair',      'kavya@gmail.com',    '9876501006'),
('Vikram Patil',    'vikram@gmail.com',   '9876501007'),
('Ananya Iyer',     'ananya@gmail.com',   '9876501008'),
('Rahul Chavan',    'rahul@gmail.com',    '9876501009'),
('Pooja Marathe',   'pooja@gmail.com',    '9876501010'),
('Nikhil Bhat',     'nikhil@gmail.com',   '9876501011'),
('Ishita Singh',    'ishita@gmail.com',   '9876501012'),
('Tanvi Kulkarni',  'tanvi@gmail.com',    '9876501013'),
('Yash Pawar',      'yash@gmail.com',     '9876501014'),
('Meera Pillai',    'meera@gmail.com',    '9876501015');

-- ─────────────────────────────────────────
--  ADDRESSES
-- ─────────────────────────────────────────
INSERT INTO Address (Street, City, Pincode, CustomerID) VALUES
('301 Sunrise Apts, FC Road',          'Pune', '411004',  1),
('B-12 Koregaon Park',                 'Pune', '411001',  2),
('22 Deccan Gymkhana',                 'Pune', '411004',  3),
('45 Baner Road',                      'Pune', '411045',  4),
('8A Aundh ITI Road',                  'Pune', '411007',  5),
('14 Viman Nagar, Near Phoenix Mall',  'Pune', '411014',  6),
('88 Kothrud, Behind Westend Mall',    'Pune', '411038',  7),
('C-5 Wakad, Hinjewadi Road',          'Pune', '411057',  8),
('Plot 12, Hadapsar, Magarpatta',      'Pune', '411013',  9),
('33 Kharadi, EON IT Park Road',       'Pune', '411014', 10),
('7th Floor, Rajiv Gandhi IT Park',    'Pune', '411057',  1),
('Hostel Block C, Symbiosis',          'Pune', '411004',  3),
('Flat 9B, Kalyani Nagar',             'Pune', '411006', 11),
('Plot 4, Wanowrie, Salunke Vihar',    'Pune', '411040', 12),
('H-11, Pimpri Colony',               'Pune', '411017', 13),
('23 Bavdhan, Near Sus Road',          'Pune', '411021', 14),
('102 Pashan Sus Road',                'Pune', '411021', 15);

-- ─────────────────────────────────────────
--  10 RESTAURANTS
-- ─────────────────────────────────────────
INSERT INTO Restaurant (RestaurantName, Location, ContactNumber) VALUES
('Vohuman Café',           'Sassoon Road, Camp, Pune',          '020-26361788'),  -- 1
('Kayani Bakery',          'East Street, Camp, Pune',           '020-26362989'),  -- 2
('Malaka Spice',           'Lane 5, Koregaon Park, Pune',       '020-26135682'),  -- 3
('Rangla Punjab',          'Pashan, Pune',                      '9960001234'),    -- 4
('The Belgian Waffle Co.', 'FC Road, Shivajinagar, Pune',       '9922334455'),    -- 5
('Café Goodluck',          'Deccan Gymkhana, Pune',             '020-25672761'),  -- 6
('Vaishali Restaurant',    'Ferguson College Road, Pune',       '020-25536553'),  -- 7
('Sujata Mastani',         'Jungli Maharaj Road, Pune',         '020-25536201'),  -- 8
('Hotel Shreyas',          'Tilak Road, Sadashiv Peth, Pune',   '020-24451047'),  -- 9
('The Flour Works',        'Koregaon Park, Lane 6, Pune',       '9820012345');    -- 10

-- ─────────────────────────────────────────
--  FOOD ITEMS (10 restaurants)
-- ─────────────────────────────────────────
INSERT INTO FoodItem (Name, Price, Availability, RestaurantID) VALUES
-- Vohuman Café (IDs 1–7)
('Bun Maska',             40,  1, 1),
('Brun Maska',            45,  1, 1),
('Egg Half Fry',          55,  1, 1),
('Chicken Sandwich',     120,  1, 1),
('Special Irani Chai',    30,  1, 1),
('Cold Coffee',           70,  1, 1),
('Lassi',                 60,  1, 1),
-- Kayani Bakery (IDs 8–13)
('Shrewsbury Biscuits',  180,  1, 2),
('Mawa Cake',             65,  1, 2),
('Khari Biscuit',         90,  1, 2),
('Wine Biscuits',        120,  1, 2),
('Cream Roll',            55,  1, 2),
('Plum Cake',             85,  1, 2),
-- Malaka Spice (IDs 14–19)
('Thai Green Curry',     380,  1, 3),
('Pad Thai Noodles',     320,  1, 3),
('Tom Yum Soup',         240,  1, 3),
('Sushi Platter 8pcs',   520,  1, 3),
('Kimchi Fried Rice',    290,  1, 3),
('Ramen Bowl',           340,  1, 3),
-- Rangla Punjab (IDs 20–26)
('Dal Makhani',          220,  1, 4),
('Paneer Butter Masala', 280,  1, 4),
('Sarson Ka Saag',       240,  1, 4),
('Tandoori Roti',         35,  1, 4),
('Butter Naan',           55,  1, 4),
('Chicken Biryani',      320,  1, 4),
('Seekh Kebab 4pcs',     280,  0, 4),  -- unavailable → Q3
-- Belgian Waffle Co. (IDs 27–32)
('Classic Choco Waffle', 180,  1, 5),
('Strawberry Sensation', 200,  1, 5),
('Nutella Overload',     220,  1, 5),
('Lotus Biscoff',        240,  1, 5),
('Oreo Milkshake',       150,  1, 5),
('Mango Smoothie',       130,  1, 5),
-- Café Goodluck (IDs 33–38)
('Chicken Berry Pulao',  340,  1, 6),
('Mutton Dhansak',       380,  1, 6),
('Akuri on Toast',       160,  1, 6),
('Cheese Omelette',      120,  1, 6),
('Irani Chai',            30,  0, 6),  -- unavailable → Q3
('Caramel Custard',       80,  1, 6),
-- Vaishali Restaurant (IDs 39–44)
('Misal Pav',             90,  1, 7),
('Vada Pav',              30,  1, 7),
('Pav Bhaji',            120,  1, 7),
('Masala Dosa',          110,  1, 7),
('Upma',                  60,  1, 7),
('Filter Coffee',         40,  1, 7),
-- Sujata Mastani (IDs 45–49)
('Classic Mastani',      150,  1, 8),
('Mango Mastani',        170,  1, 8),
('Strawberry Mastani',   160,  1, 8),
('Chocolate Mastani',    180,  1, 8),
('Kesar Pista Mastani',  190,  1, 8),
-- Hotel Shreyas (IDs 50–55)
('Thali Meal',           180,  1, 9),
('Shrikhand',             80,  1, 9),
('Puran Poli',            60,  1, 9),
('Bharli Vangi',         140,  1, 9),
('Sol Kadhi',             50,  1, 9),
('Basundi',               90,  1, 9),
-- The Flour Works (IDs 56–61)
('Wood-fired Pizza',     450,  1, 10),
('Pasta Arrabiata',      320,  1, 10),
('Tiramisu',             220,  1, 10),
('Bruschetta',           180,  1, 10),
('Mushroom Risotto',     390,  1, 10),
('Lemon Tart',           190,  1, 10);

-- ─────────────────────────────────────────
--  ORDERS
--  Jan 2026  : 1–40   (history, all 7 weekdays)
--  Feb 2026  : 41–80  (history, Q4 filter range)
--  Mar 2026  : 81–120 (current month, Q4 + Q5)
--  Order 80  : unavailable item, no payment → Q3
--
--  Jan 2026 weekday reference:
--  05=Mon 06=Tue 07=Wed 08=Thu 09=Fri 10=Sat 11=Sun
--  12=Mon 13=Tue 14=Wed 15=Thu 16=Fri 17=Sat 18=Sun
--  Feb 2026 weekday reference:
--  02=Mon 03=Tue 04=Wed 05=Thu 06=Fri 07=Sat 08=Sun
-- ─────────────────────────────────────────
INSERT INTO `Order` (OrderDate, OrderStatus, CustomerID, RestaurantID) VALUES
-- ══ JANUARY 2026 (Orders 1–40) ══
('2026-01-05', 'Delivered',  3,  3),  --  1 Mon
('2026-01-05', 'Delivered',  6,  7),  --  2 Mon
('2026-01-06', 'Delivered',  5,  1),  --  3 Tue
('2026-01-06', 'Delivered', 11, 10),  --  4 Tue
('2026-01-07', 'Delivered',  1,  2),  --  5 Wed
('2026-01-07', 'Delivered', 12,  8),  --  6 Wed
('2026-01-08', 'Delivered',  7,  4),  --  7 Thu
('2026-01-08', 'Delivered', 13,  9),  --  8 Thu
('2026-01-09', 'Delivered',  3,  6),  --  9 Fri
('2026-01-09', 'Delivered', 14,  3),  -- 10 Fri
('2026-01-10', 'Delivered',  8,  3),  -- 11 Sat
('2026-01-10', 'Delivered', 15,  5),  -- 12 Sat
('2026-01-11', 'Delivered',  2,  5),  -- 13 Sun
('2026-01-11', 'Delivered',  9,  7),  -- 14 Sun
('2026-01-12', 'Delivered',  4,  1),  -- 15 Mon
('2026-01-12', 'Delivered', 10,  8),  -- 16 Mon
('2026-01-13', 'Delivered',  3,  3),  -- 17 Tue
('2026-01-13', 'Delivered', 11,  9),  -- 18 Tue
('2026-01-14', 'Delivered',  6,  6),  -- 19 Wed
('2026-01-14', 'Delivered', 12, 10),  -- 20 Wed
('2026-01-15', 'Delivered',  5,  2),  -- 21 Thu
('2026-01-15', 'Delivered', 13,  3),  -- 22 Thu
('2026-01-16', 'Delivered',  7,  4),  -- 23 Fri
('2026-01-16', 'Delivered', 14,  7),  -- 24 Fri
('2026-01-17', 'Delivered',  1,  3),  -- 25 Sat
('2026-01-17', 'Delivered', 15,  2),  -- 26 Sat
('2026-01-18', 'Delivered',  8,  5),  -- 27 Sun
('2026-01-18', 'Delivered',  9,  6),  -- 28 Sun
('2026-01-19', 'Delivered',  3,  3),  -- 29 Mon
('2026-01-19', 'Delivered', 10,  4),  -- 30 Mon
('2026-01-20', 'Delivered',  2,  3),  -- 31 Tue
('2026-01-20', 'Delivered', 11,  8),  -- 32 Tue
('2026-01-21', 'Delivered',  4,  6),  -- 33 Wed
('2026-01-22', 'Delivered',  6,  3),  -- 34 Thu
('2026-01-23', 'Delivered',  3,  6),  -- 35 Fri
('2026-01-24', 'Delivered',  7,  2),  -- 36 Sat
('2026-01-25', 'Delivered',  5,  3),  -- 37 Sun
('2026-01-26', 'Cancelled', 12,  1),  -- 38 Mon cancelled
('2026-01-27', 'Delivered',  1,  4),  -- 39 Tue
('2026-01-28', 'Delivered', 13,  3),  -- 40 Wed
-- ══ FEBRUARY 2026 (Orders 41–80) ══
('2026-02-02', 'Delivered',  3,  3),  -- 41 Mon
('2026-02-02', 'Delivered',  6,  7),  -- 42 Mon
('2026-02-03', 'Delivered',  5,  1),  -- 43 Tue
('2026-02-03', 'Delivered', 11, 10),  -- 44 Tue
('2026-02-04', 'Delivered',  1,  2),  -- 45 Wed
('2026-02-04', 'Delivered', 12,  8),  -- 46 Wed
('2026-02-05', 'Delivered',  7,  9),  -- 47 Thu
('2026-02-05', 'Delivered', 13,  4),  -- 48 Thu
('2026-02-06', 'Delivered',  3,  6),  -- 49 Fri
('2026-02-06', 'Delivered', 14,  3),  -- 50 Fri
('2026-02-06', 'Delivered',  2, 10),  -- 51 Fri
('2026-02-07', 'Delivered',  8,  3),  -- 52 Sat
('2026-02-07', 'Delivered', 15,  5),  -- 53 Sat
('2026-02-07', 'Delivered',  4,  2),  -- 54 Sat
('2026-02-08', 'Delivered',  9,  7),  -- 55 Sun
('2026-02-08', 'Delivered',  3,  3),  -- 56 Sun
('2026-02-08', 'Delivered', 10,  8),  -- 57 Sun
('2026-02-09', 'Delivered',  3,  3),  -- 58 Mon
('2026-02-09', 'Delivered',  5,  6),  -- 59 Mon
('2026-02-10', 'Delivered',  6,  4),  -- 60 Tue
('2026-02-10', 'Delivered', 11,  3),  -- 61 Tue
('2026-02-11', 'Delivered',  1,  5),  -- 62 Wed
('2026-02-11', 'Delivered', 12,  9),  -- 63 Wed
('2026-02-12', 'Delivered',  3,  3),  -- 64 Thu
('2026-02-12', 'Delivered', 13,  7),  -- 65 Thu
('2026-02-13', 'Delivered',  7,  2),  -- 66 Fri
('2026-02-13', 'Delivered', 14,  6),  -- 67 Fri
('2026-02-14', 'Delivered',  8,  3),  -- 68 Sat
('2026-02-14', 'Delivered', 15, 10),  -- 69 Sat
('2026-02-15', 'Delivered',  2,  5),  -- 70 Sun
('2026-02-15', 'Delivered',  9,  3),  -- 71 Sun
('2026-02-16', 'Delivered',  3,  6),  -- 72 Mon
('2026-02-17', 'Delivered',  4,  3),  -- 73 Tue
('2026-02-18', 'Delivered',  5,  1),  -- 74 Wed
('2026-02-19', 'Delivered',  6,  4),  -- 75 Thu
('2026-02-20', 'Delivered',  3,  3),  -- 76 Fri
('2026-02-21', 'Delivered', 10,  2),  -- 77 Sat
('2026-02-22', 'Delivered',  7,  3),  -- 78 Sun
('2026-02-24', 'Cancelled', 11,  1),  -- 79 Tue cancelled
('2026-02-14', 'Placed',     2,  4),  -- 80 unavailable item, no payment → Q3
-- ══ MARCH 2026 — current month (Orders 81–120) ══
-- Rohan (CustomerID 3) — most active, 7 orders
(DATE_SUB(CURDATE(), INTERVAL  1 DAY), 'Delivered',  3,  3),  -- 81
(DATE_SUB(CURDATE(), INTERVAL  4 DAY), 'Delivered',  3,  6),  -- 82
(DATE_SUB(CURDATE(), INTERVAL  7 DAY), 'Delivered',  3,  3),  -- 83
(DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Delivered',  3,  1),  -- 84
(DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Delivered',  3,  7),  -- 85
(DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'Delivered',  3,  3),  -- 86
(DATE_SUB(CURDATE(), INTERVAL 19 DAY), 'Delivered',  3,  2),  -- 87
-- Arjun (CustomerID 5) — 6 orders
(DATE_SUB(CURDATE(), INTERVAL  2 DAY), 'Delivered',  5,  3),  -- 88
(DATE_SUB(CURDATE(), INTERVAL  5 DAY), 'Delivered',  5,  6),  -- 89
(DATE_SUB(CURDATE(), INTERVAL  9 DAY), 'Delivered',  5,  3),  -- 90
(DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Delivered',  5, 10),  -- 91
(DATE_SUB(CURDATE(), INTERVAL 17 DAY), 'Delivered',  5,  3),  -- 92
(DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Delivered',  5,  1),  -- 93
-- Kavya (CustomerID 6) — 5 orders
(DATE_SUB(CURDATE(), INTERVAL  3 DAY), 'Delivered',  6,  4),  -- 94
(DATE_SUB(CURDATE(), INTERVAL  6 DAY), 'Delivered',  6,  7),  -- 95
(DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Delivered',  6,  3),  -- 96
(DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'Delivered',  6,  8),  -- 97
(DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Delivered',  6,  2),  -- 98
-- Aarav (CustomerID 1) — 4 orders
(DATE_SUB(CURDATE(), INTERVAL  3 DAY), 'Delivered',  1,  2),  -- 99
(DATE_SUB(CURDATE(), INTERVAL  8 DAY), 'Delivered',  1,  3),  -- 100
(DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered',  1,  9),  -- 101
(DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Delivered',  1,  6),  -- 102
-- Vikram (CustomerID 7) — 4 orders
(DATE_SUB(CURDATE(), INTERVAL  4 DAY), 'Delivered',  7,  3),  -- 103
(DATE_SUB(CURDATE(), INTERVAL  9 DAY), 'Delivered',  7,  5),  -- 104
(DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Delivered',  7, 10),  -- 105
(DATE_SUB(CURDATE(), INTERVAL 19 DAY), 'Delivered',  7,  1),  -- 106
-- Priya (CustomerID 2) — 3 orders
(DATE_SUB(CURDATE(), INTERVAL  5 DAY), 'Delivered',  2,  4),  -- 107
(DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Delivered',  2,  3),  -- 108
(DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Delivered',  2,  7),  -- 109
-- Nikhil (CustomerID 11) — 3 orders
(DATE_SUB(CURDATE(), INTERVAL  6 DAY), 'Delivered', 11,  8),  -- 110
(DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered', 11,  3),  -- 111
(DATE_SUB(CURDATE(), INTERVAL 17 DAY), 'Delivered', 11,  9),  -- 112
-- Sneha (CustomerID 4) — 2 orders
(DATE_SUB(CURDATE(), INTERVAL  7 DAY), 'Delivered',  4,  5),  -- 113
(DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'Delivered',  4,  3),  -- 114
-- Tanvi (CustomerID 13) — 2 orders
(DATE_SUB(CURDATE(), INTERVAL  8 DAY), 'Delivered', 13,  7),  -- 115
(DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Delivered', 13,  4),  -- 116
-- Ananya (CustomerID 8) — 2 orders
(DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Delivered',  8,  6),  -- 117
(DATE_SUB(CURDATE(), INTERVAL 19 DAY), 'Delivered',  8,  3),  -- 118
-- Yash (CustomerID 14) — 1 order
(DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Delivered', 14, 10),  -- 119
-- Meera (CustomerID 15) — 1 order
(DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'Delivered', 15,  5);  -- 120

-- ─────────────────────────────────────────
--  ORDER ITEMS
-- ─────────────────────────────────────────
INSERT INTO OrderItem (OrderID, FoodItemID, Quantity, ItemPrice) VALUES
-- January (1–40)
(1,  14, 4, 380), (1,  15, 3, 320),
(2,  39, 3,  90), (2,  42, 2,  40),
(3,   1, 3,  40), (3,   5, 4,  30),
(4,  56, 2, 450), (4,  58, 1, 180),
(5,   8, 3, 180), (5,   9, 2,  65),
(6,  45, 2, 150), (6,  47, 1, 160),
(7,  20, 2, 220), (7,  26, 1, 320),
(8,  50, 2, 180), (8,  52, 1,  60),
(9,  33, 2, 340), (9,  36, 3,  80),
(10, 14, 4, 380), (10, 18, 2, 290),
(11, 14, 5, 380), (11, 17, 2, 520),
(12, 27, 3, 180), (12, 31, 2, 150),
(13, 27, 2, 180), (13, 30, 1, 240),
(14, 39, 3,  90), (14, 41, 2, 110),
(15,  1, 4,  40), (15,  5, 5,  30),
(16, 45, 3, 150), (16, 46, 2, 170),
(17, 14, 5, 380), (17, 15, 4, 320),
(18, 50, 2, 180), (18, 53, 1,  80),
(19, 33, 3, 340), (19, 34, 2, 380),
(20, 56, 2, 450), (20, 59, 1, 390),
(21,  8, 3, 180), (21, 12, 2,  55),
(22,  1, 2,  40), (22,  5, 1,  30),
(23, 20, 2, 220), (23, 25, 1, 320),
(24, 39, 3,  90), (24, 40, 2, 110),
(25, 14, 4, 380), (25, 16, 2, 240),
(26, 27, 3, 180), (26, 31, 2, 150),
(27, 27, 2, 180), (27, 29, 1, 220),
(28, 33, 2, 340), (28, 38, 2,  80),
(29, 14, 5, 380), (29, 15, 4, 320),
(30, 20, 2, 220), (30, 26, 1, 320),
(31, 14, 4, 380), (31, 18, 3, 290),
(32, 45, 3, 150), (32, 48, 2, 180),
(33, 33, 2, 340), (33, 35, 2, 160),
(34, 14, 4, 380), (34, 16, 3, 240),
(35, 33, 3, 340), (35, 36, 2,  80),
(36,  8, 3, 180), (36, 13, 1,  85),
(37, 14, 4, 380), (37, 15, 3, 320),
(38,  1, 2,  40), (38,  5, 1,  30),
(39, 20, 2, 220), (39, 24, 3,  35),
(40, 14, 4, 380), (40, 17, 2, 520),
-- February (41–80)
(41, 14, 4, 380), (41, 15, 3, 320),
(42, 39, 3,  90), (42, 42, 2,  40),
(43,  1, 3,  40), (43,  5, 4,  30),
(44, 56, 2, 450), (44, 57, 1, 320),
(45,  8, 3, 180), (45,  9, 2,  65),
(46, 45, 2, 150), (46, 49, 1, 190),
(47, 50, 2, 180), (47, 54, 1,  50),
(48, 20, 2, 220), (48, 25, 2,  55),
(49, 33, 3, 340), (49, 36, 2,  80),
(50, 14, 5, 380), (50, 17, 2, 520),
(51, 56, 2, 450), (51, 59, 1, 390),
(52, 14, 4, 380), (52, 18, 2, 290),
(53, 27, 3, 180), (53, 31, 2, 150),
(54,  8, 2, 180), (54, 12, 2,  55),
(55, 39, 3,  90), (55, 41, 2, 110),
(56, 14, 5, 380), (56, 15, 4, 320),
(57, 45, 2, 150), (57, 46, 2, 170),
(58, 14, 4, 380), (58, 16, 2, 240),
(59, 33, 2, 340), (59, 35, 3, 160),
(60, 20, 2, 220), (60, 24, 3,  35),
(61, 14, 5, 380), (61, 15, 4, 320),
(62,  8, 3, 180), (62, 13, 1,  85),
(63, 50, 2, 180), (63, 53, 1,  80),
(64, 14, 4, 380), (64, 18, 3, 290),
(65, 39, 3,  90), (65, 42, 2,  40),
(66,  8, 3, 180), (66, 12, 2,  55),
(67, 33, 3, 340), (67, 34, 2, 380),
(68, 14, 5, 380), (68, 17, 2, 520),
(69, 56, 2, 450), (69, 58, 1, 180),
(70, 27, 3, 180), (70, 31, 2, 150),
(71, 14, 4, 380), (71, 15, 3, 320),
(72, 33, 2, 340), (72, 36, 2,  80),
(73, 14, 5, 380), (73, 18, 3, 290),
(74,  1, 3,  40), (74,  5, 4,  30),
(75, 20, 2, 220), (75, 26, 1, 320),
(76, 14, 4, 380), (76, 15, 3, 320),
(77,  8, 3, 180), (77, 13, 1,  85),
(78, 14, 5, 380), (78, 17, 2, 520),
(79,  1, 2,  40), (79,  5, 1,  30),
(80, 27, 2, 280),   -- Seekh Kebab unavailable → Q3
-- March (81–120)
(81,  14, 3, 380), (81,  15, 2, 320),
(82,  33, 2, 340), (82,  35, 2, 160),
(83,  14, 4, 380), (83,  18, 2, 290),
(84,   1, 4,  40), (84,   5, 3,  30),
(85,  39, 3,  90), (85,  42, 2,  40),
(86,  14, 5, 380), (86,  15, 4, 320),
(87,   8, 3, 180), (87,   9, 2,  65),
(88,  14, 3, 380), (88,  16, 2, 240),
(89,  33, 2, 340), (89,  36, 2,  80),
(90,  14, 4, 380), (90,  15, 3, 320),
(91,  56, 2, 450), (91,  57, 1, 320),
(92,  14, 5, 380), (92,  18, 3, 290),
(93,   1, 3,  40), (93,   5, 4,  30),
(94,  20, 2, 220), (94,  26, 1, 320),
(95,  39, 3,  90), (95,  41, 2, 110),
(96,  14, 4, 380), (96,  17, 2, 520),
(97,  45, 2, 150), (97,  47, 1, 160),
(98,   8, 3, 180), (98,  13, 1,  85),
(99,   8, 2, 180), (99,   9, 2,  65),
(100, 14, 3, 380), (100, 15, 2, 320),
(101, 50, 2, 180), (101, 53, 1,  80),
(102, 33, 2, 340), (102, 34, 2, 380),
(103, 14, 4, 380), (103, 17, 2, 520),
(104, 27, 2, 180), (104, 31, 1, 150),
(105, 56, 2, 450), (105, 59, 1, 390),
(106,  1, 3,  40), (106,  6, 2,  70),
(107, 20, 2, 220), (107, 25, 2,  55),
(108, 14, 3, 380), (108, 15, 2, 320),
(109, 39, 2,  90), (109, 42, 2,  40),
(110, 45, 3, 150), (110, 48, 2, 180),
(111, 14, 4, 380), (111, 18, 2, 290),
(112, 50, 2, 180), (112, 53, 1,  80),
(113, 27, 2, 180), (113, 29, 2, 220),
(114, 14, 3, 380), (114, 15, 2, 320),
(115, 39, 3,  90), (115, 41, 2, 110),
(116, 20, 2, 220), (116, 26, 1, 320),
(117, 33, 2, 340), (117, 35, 2, 160),
(118, 14, 3, 380), (118, 16, 1, 240),
(119, 56, 2, 450), (119, 58, 1, 180),
(120, 27, 2, 180), (120, 31, 1, 150);

-- ─────────────────────────────────────────
--  PAYMENTS  (Order 80 → NO payment row)
-- ─────────────────────────────────────────
INSERT INTO Payment (PaymentMethod, PaymentStatus, PaymentDate, OrderID) VALUES
('UPI',    'Paid',    '2026-01-05',  1), ('Card',   'Paid',    '2026-01-05',  2),
('UPI',    'Paid',    '2026-01-06',  3), ('Wallet', 'Paid',    '2026-01-06',  4),
('UPI',    'Paid',    '2026-01-07',  5), ('Cash',   'Pending', '2026-01-07',  6),
('Card',   'Paid',    '2026-01-08',  7), ('UPI',    'Paid',    '2026-01-08',  8),
('UPI',    'Paid',    '2026-01-09',  9), ('Card',   'Paid',    '2026-01-09', 10),
('UPI',    'Paid',    '2026-01-10', 11), ('Wallet', 'Paid',    '2026-01-10', 12),
('UPI',    'Paid',    '2026-01-11', 13), ('Cash',   'Pending', '2026-01-11', 14),
('Card',   'Paid',    '2026-01-12', 15), ('UPI',    'Paid',    '2026-01-12', 16),
('UPI',    'Paid',    '2026-01-13', 17), ('Wallet', 'Paid',    '2026-01-13', 18),
('UPI',    'Paid',    '2026-01-14', 19), ('Card',   'Paid',    '2026-01-14', 20),
('UPI',    'Paid',    '2026-01-15', 21), ('UPI',    'Paid',    '2026-01-15', 22),
('Card',   'Paid',    '2026-01-16', 23), ('Cash',   'Pending', '2026-01-16', 24),
('UPI',    'Paid',    '2026-01-17', 25), ('Wallet', 'Paid',    '2026-01-17', 26),
('UPI',    'Paid',    '2026-01-18', 27), ('Card',   'Paid',    '2026-01-18', 28),
('UPI',    'Paid',    '2026-01-19', 29), ('UPI',    'Paid',    '2026-01-19', 30),
('Card',   'Paid',    '2026-01-20', 31), ('UPI',    'Paid',    '2026-01-20', 32),
('Wallet', 'Paid',    '2026-01-21', 33), ('UPI',    'Paid',    '2026-01-22', 34),
('UPI',    'Paid',    '2026-01-23', 35), ('Card',   'Paid',    '2026-01-24', 36),
('UPI',    'Paid',    '2026-01-25', 37), ('UPI',    'Failed',  '2026-01-26', 38),
('Cash',   'Pending', '2026-01-27', 39), ('Card',   'Paid',    '2026-01-28', 40),
('UPI',    'Paid',    '2026-02-02', 41), ('Card',   'Paid',    '2026-02-02', 42),
('UPI',    'Paid',    '2026-02-03', 43), ('Wallet', 'Paid',    '2026-02-03', 44),
('UPI',    'Paid',    '2026-02-04', 45), ('Cash',   'Pending', '2026-02-04', 46),
('Card',   'Paid',    '2026-02-05', 47), ('UPI',    'Paid',    '2026-02-05', 48),
('UPI',    'Paid',    '2026-02-06', 49), ('Card',   'Paid',    '2026-02-06', 50),
('Wallet', 'Paid',    '2026-02-06', 51), ('UPI',    'Paid',    '2026-02-07', 52),
('UPI',    'Paid',    '2026-02-07', 53), ('Card',   'Paid',    '2026-02-07', 54),
('Cash',   'Pending', '2026-02-08', 55), ('UPI',    'Paid',    '2026-02-08', 56),
('Wallet', 'Paid',    '2026-02-08', 57), ('UPI',    'Paid',    '2026-02-09', 58),
('Card',   'Paid',    '2026-02-09', 59), ('UPI',    'Paid',    '2026-02-10', 60),
('UPI',    'Paid',    '2026-02-10', 61), ('Card',   'Paid',    '2026-02-11', 62),
('Wallet', 'Paid',    '2026-02-11', 63), ('UPI',    'Paid',    '2026-02-12', 64),
('UPI',    'Paid',    '2026-02-12', 65), ('Card',   'Paid',    '2026-02-13', 66),
('UPI',    'Paid',    '2026-02-13', 67), ('UPI',    'Paid',    '2026-02-14', 68),
('Wallet', 'Paid',    '2026-02-14', 69), ('Card',   'Paid',    '2026-02-15', 70),
('UPI',    'Paid',    '2026-02-15', 71), ('UPI',    'Paid',    '2026-02-16', 72),
('Card',   'Paid',    '2026-02-17', 73), ('UPI',    'Paid',    '2026-02-18', 74),
('Cash',   'Pending', '2026-02-19', 75), ('UPI',    'Paid',    '2026-02-20', 76),
('Wallet', 'Paid',    '2026-02-21', 77), ('Card',   'Paid',    '2026-02-22', 78),
('UPI',    'Failed',  '2026-02-24', 79),
-- Order 80 → intentionally NO payment row (NOT EXISTS → Q3)
-- March 2026
('UPI',    'Paid',    CURDATE(),  81), ('Card',   'Paid',    CURDATE(),  82),
('UPI',    'Paid',    CURDATE(),  83), ('Wallet', 'Paid',    CURDATE(),  84),
('UPI',    'Paid',    CURDATE(),  85), ('UPI',    'Paid',    CURDATE(),  86),
('Card',   'Paid',    CURDATE(),  87), ('UPI',    'Paid',    CURDATE(),  88),
('UPI',    'Paid',    CURDATE(),  89), ('Wallet', 'Paid',    CURDATE(),  90),
('Card',   'Paid',    CURDATE(),  91), ('UPI',    'Paid',    CURDATE(),  92),
('Cash',   'Pending', CURDATE(),  93), ('UPI',    'Paid',    CURDATE(),  94),
('Card',   'Paid',    CURDATE(),  95), ('UPI',    'Paid',    CURDATE(),  96),
('UPI',    'Paid',    CURDATE(),  97), ('Wallet', 'Paid',    CURDATE(),  98),
('UPI',    'Paid',    CURDATE(),  99), ('Card',   'Paid',    CURDATE(), 100),
('UPI',    'Paid',    CURDATE(), 101), ('UPI',    'Paid',    CURDATE(), 102),
('UPI',    'Paid',    CURDATE(), 103), ('Wallet', 'Paid',    CURDATE(), 104),
('Card',   'Paid',    CURDATE(), 105), ('Cash',   'Pending', CURDATE(), 106),
('UPI',    'Paid',    CURDATE(), 107), ('Card',   'Paid',    CURDATE(), 108),
('UPI',    'Paid',    CURDATE(), 109), ('UPI',    'Paid',    CURDATE(), 110),
('Wallet', 'Paid',    CURDATE(), 111), ('Card',   'Paid',    CURDATE(), 112),
('UPI',    'Paid',    CURDATE(), 113), ('UPI',    'Paid',    CURDATE(), 114),
('Card',   'Paid',    CURDATE(), 115), ('Cash',   'Pending', CURDATE(), 116),
('UPI',    'Paid',    CURDATE(), 117), ('Wallet', 'Paid',    CURDATE(), 118),
('Card',   'Paid',    CURDATE(), 119), ('UPI',    'Paid',    CURDATE(), 120);

-- ─────────────────────────────────────────
--  DELIVERY PARTNERS (March orders → Q5)
--  Sanjay = 7 deliveries → clear #1
-- ─────────────────────────────────────────
INSERT INTO DeliveryPartner (Name, Phone, VehicleType, OrderID) VALUES
('Sanjay Patil',  '9876541001', 'Bike',    81),
('Rahul Shinde',  '9876541002', 'Scooter', 82),
('Amit Waghmare', '9876541003', 'Bike',    83),
('Ganesh Jadhav', '9876541004', 'Scooter', 84),
('Vijay Kale',    '9876541005', 'Bike',    85),
('Sanjay Patil',  '9876541001', 'Bike',    86),
('Rahul Shinde',  '9876541002', 'Scooter', 87),
('Amit Waghmare', '9876541003', 'Bike',    88),
('Sanjay Patil',  '9876541001', 'Bike',    89),
('Ganesh Jadhav', '9876541004', 'Scooter', 90),
('Rahul Shinde',  '9876541002', 'Scooter', 91),
('Vijay Kale',    '9876541005', 'Bike',    92),
('Sanjay Patil',  '9876541001', 'Bike',    93),
('Amit Waghmare', '9876541003', 'Bike',    94),
('Ganesh Jadhav', '9876541004', 'Scooter', 95),
('Vijay Kale',    '9876541005', 'Bike',    96),
('Rahul Shinde',  '9876541002', 'Scooter', 97),
('Sanjay Patil',  '9876541001', 'Bike',    98),
('Amit Waghmare', '9876541003', 'Bike',    99),
('Ganesh Jadhav', '9876541004', 'Scooter',100),
('Vijay Kale',    '9876541005', 'Bike',   101),
('Sanjay Patil',  '9876541001', 'Bike',   102),
('Rahul Shinde',  '9876541002', 'Scooter',103),
('Amit Waghmare', '9876541003', 'Bike',   104),
('Ganesh Jadhav', '9876541004', 'Scooter',105),
('Vijay Kale',    '9876541005', 'Bike',   106),
('Sanjay Patil',  '9876541001', 'Bike',   107),
('Rahul Shinde',  '9876541002', 'Scooter',108),
('Amit Waghmare', '9876541003', 'Bike',   109),
('Ganesh Jadhav', '9876541004', 'Scooter',110),
('Vijay Kale',    '9876541005', 'Bike',   111),
('Rahul Shinde',  '9876541002', 'Scooter',112),
('Sanjay Patil',  '9876541001', 'Bike',   113),
('Amit Waghmare', '9876541003', 'Bike',   114),
('Ganesh Jadhav', '9876541004', 'Scooter',115),
('Vijay Kale',    '9876541005', 'Bike',   116),
('Rahul Shinde',  '9876541002', 'Scooter',117),
('Amit Waghmare', '9876541003', 'Bike',   118),
('Sanjay Patil',  '9876541001', 'Bike',   119),
('Ganesh Jadhav', '9876541004', 'Scooter',120);

-- ─────────────────────────────────────────
--  REVIEWS (8–10 per restaurant → HAVING COUNT > 5 passes for all 10)
--  Malaka Spice: highest ratings → clear Q1 winner
-- ─────────────────────────────────────────
INSERT INTO Review (Rating, Comment, ReviewDate, CustomerID, RestaurantID) VALUES
-- Vohuman Café (8)
(5.0, 'Best Irani chai in Pune!',         '2026-01-10',  1, 1),
(4.5, 'Bun Maska every morning',          '2026-01-15',  2, 1),
(4.8, 'Authentic old Pune vibe',          '2026-01-20',  3, 1),
(4.7, 'Classic breakfast spot',           '2026-02-07',  5, 1),
(4.6, 'Simple and consistently great',   '2026-02-12',  6, 1),
(5.0, 'Best chai, period.',               '2026-02-18',  7, 1),
(4.9, 'Never disappoints',               '2026-02-22',  8, 1),
(4.8, 'Egg half fry is underrated',       '2026-02-25', 11, 1),
-- Kayani Bakery (8)
(4.9, 'Shrewsbury biscuits legendary',   '2026-01-08',  2, 2),
(5.0, 'Mawa cake is divine',             '2026-01-14',  4, 2),
(4.8, 'Kayani never disappoints',        '2026-01-20',  3, 2),
(4.7, 'Worth the queue every time',      '2026-02-04',  1, 2),
(4.6, 'Cream rolls fresh daily',         '2026-02-10', 12, 2),
(4.9, 'Iconic Pune institution',         '2026-02-17', 13, 2),
(4.8, 'Plum cake was rich',              '2026-02-23', 14, 2),
(4.7, 'Khari biscuits addictive',        '2026-02-27', 15, 2),
-- Malaka Spice (10 — highest rated → clear Q1 winner)
(5.0, 'Pad Thai absolutely perfect',     '2026-01-06',  3, 3),
(4.9, 'Tom Yum soup incredible',         '2026-01-11',  5, 3),
(4.8, 'Sushi was super fresh',           '2026-01-18',  1, 3),
(4.9, 'Amazing KP ambiance',             '2026-01-23',  7, 3),
(5.0, 'Best Pan-Asian in Pune',          '2026-02-02',  4, 3),
(4.8, 'Kimchi fried rice addictive',     '2026-02-09',  8, 3),
(5.0, 'Thai green curry top notch',      '2026-02-14', 11, 3),
(4.9, 'Ramen bowl was comforting',       '2026-02-19',  2, 3),
(5.0, 'Best restaurant in Pune',         '2026-02-25',  3, 3),
(4.8, 'Every visit is worth it',         '2026-02-28', 12, 3),
-- Rangla Punjab (8)
(4.2, 'Dal Makhani very creamy',         '2026-01-09',  4, 4),
(4.3, 'Good dhaba vibes',                '2026-01-15',  1, 4),
(4.0, 'Value for money',                 '2026-01-22', 13, 4),
(4.1, 'Chicken biryani was good',        '2026-02-05',  2, 4),
(4.4, 'Butter naan was fluffy',          '2026-02-11',  6, 4),
(4.2, 'Will visit again',               '2026-02-18', 14, 4),
(4.3, 'Sarson ka saag authentic',        '2026-02-24',  7, 4),
(4.0, 'Great Punjabi food',              '2026-02-27', 15, 4),
-- Belgian Waffle Co. (8)
(4.0, 'Nutella waffle was rich',         '2026-01-11',  5, 5),
(4.2, 'Worth every rupee',               '2026-01-17',  2, 5),
(4.3, 'Lotus Biscoff waffle amazing',    '2026-01-24',  8, 5),
(4.1, 'Oreo milkshake was thick',        '2026-02-03',  3, 5),
(4.0, 'Nice FC Road spot',               '2026-02-10',  9, 5),
(4.2, 'Great dessert place',             '2026-02-16', 10, 5),
(4.3, 'Mango smoothie was fresh',        '2026-02-22', 11, 5),
(4.1, 'Strawberry waffle was sweet',     '2026-02-26', 12, 5),
-- Café Goodluck (9)
(4.8, 'Berry Pulao is iconic',           '2026-01-10',  1, 6),
(4.7, 'Mutton Dhansak wow',              '2026-01-16',  3, 6),
(4.6, 'Irani chai great as always',      '2026-01-22',  5, 6),
(4.9, 'Best Parsi food in the city',     '2026-02-03',  2, 6),
(5.0, 'Akuri on toast is perfect',       '2026-02-09',  4, 6),
(4.8, 'Always open, always good',        '2026-02-15', 13, 6),
(4.7, 'Cheese omelette was fluffy',      '2026-02-20', 14, 6),
(4.9, 'Historic place, great food',      '2026-02-25', 15, 6),
(4.8, 'Caramel custard divine',          '2026-02-28',  6, 6),
-- Vaishali Restaurant (8)
(4.5, 'Best Misal Pav in Pune!',         '2026-01-07',  1, 7),
(4.6, 'Masala Dosa crispy and perfect',  '2026-01-13',  2, 7),
(4.4, 'Vada Pav is iconic here',         '2026-01-20',  3, 7),
(4.7, 'Filter coffee excellent',         '2026-02-04',  6, 7),
(4.5, 'Pav Bhaji was buttery rich',      '2026-02-11',  7, 7),
(4.6, 'Classic FC Road spot',            '2026-02-17',  8, 7),
(4.4, 'Upma was light and tasty',        '2026-02-23',  9, 7),
(4.5, 'Always consistent quality',       '2026-02-27', 10, 7),
-- Sujata Mastani (8)
(4.7, 'Mastani is one of a kind!',       '2026-01-08',  4, 8),
(4.8, 'Mango Mastani was heavenly',      '2026-01-14',  5, 8),
(4.6, 'Classic Mastani never fails',     '2026-01-22',  6, 8),
(4.9, 'Kesar Pista Mastani was divine',  '2026-02-05', 11, 8),
(4.7, 'Chocolate one is amazing',        '2026-02-12', 12, 8),
(4.8, 'Thick and creamy always',         '2026-02-18', 13, 8),
(4.6, 'Worth every rupee',              '2026-02-24', 14, 8),
(4.7, 'Best Mastani in Pune',            '2026-02-28', 15, 8),
-- Hotel Shreyas (8)
(4.4, 'Thali was wholesome meal',        '2026-01-09',  2, 9),
(4.5, 'Puran Poli was authentic',        '2026-01-15',  3, 9),
(4.3, 'Shrikhand perfect texture',       '2026-01-21',  4, 9),
(4.6, 'Basundi was rich and creamy',     '2026-02-06',  1, 9),
(4.4, 'Sol Kadhi very refreshing',       '2026-02-13',  5, 9),
(4.5, 'Bharli Vangi was authentic',      '2026-02-20',  6, 9),
(4.3, 'Good traditional Maharashtrian',  '2026-02-25',  7, 9),
(4.4, 'Thali value for money',           '2026-02-28',  8, 9),
-- The Flour Works (8)
(4.6, 'Wood-fired pizza is amazing!',    '2026-01-10',  1, 10),
(4.7, 'Pasta Arrabiata was perfect',     '2026-01-17',  2, 10),
(4.5, 'Tiramisu was heavenly',           '2026-01-24',  3, 10),
(4.8, 'Best continental in KP',         '2026-02-07',  4, 10),
(4.6, 'Mushroom Risotto was creamy',     '2026-02-14',  5, 10),
(4.7, 'Bruschetta was crunchy fresh',    '2026-02-20', 11, 10),
(4.5, 'Lemon Tart tangy and perfect',   '2026-02-25', 12, 10),
(4.6, 'Great ambiance and food',         '2026-02-28', 13, 10);

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
SELECT '✅ Database ready! 15 customers · 10 restaurants · 120 orders' AS Status;

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
LIMIT 5;

SELECT '═══ Q2: Restaurant Peak Days ═══' AS '';
SELECT r.RestaurantName,
       DAYNAME(o.OrderDate)            AS DayOfWeek,
       COUNT(o.OrderID)                AS TotalOrders
FROM Restaurant r
JOIN `Order`   o  ON r.RestaurantID = o.RestaurantID
JOIN OrderItem oi ON o.OrderID      = oi.OrderID
WHERE o.OrderStatus != 'Cancelled'
GROUP BY r.RestaurantID, r.RestaurantName,
         DAYNAME(o.OrderDate), DAYOFWEEK(o.OrderDate)
ORDER BY r.RestaurantName, DAYOFWEEK(o.OrderDate);

SELECT '═══ Q3: Top 5 Popular Food Items ═══' AS '';
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

SELECT '═══ Q4: Most Active Customers — February 2026 ═══' AS '';
SELECT c.CustomerName,
       COUNT(o.OrderID)                            AS OrdersThisMonth,
       SUM(oi.Quantity * oi.ItemPrice)             AS MonthlySpend,
       DATE_FORMAT(MAX(o.OrderDate), '%d %b %Y')   AS LastOrderDate
FROM CustomerOrderSummary cos
JOIN Customer  c  ON cos.CustomerID = c.CustomerID
JOIN `Order`   o  ON c.CustomerID   = o.CustomerID
JOIN OrderItem oi ON o.OrderID      = oi.OrderID
WHERE o.OrderDate >= '2026-02-01'
  AND o.OrderDate <  '2026-03-01'
  AND o.OrderStatus != 'Cancelled'
GROUP BY c.CustomerID, c.CustomerName
ORDER BY OrdersThisMonth DESC, MonthlySpend DESC;

SELECT '═══ Q5: Top Delivery Partners — March 2026 ═══' AS '';
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