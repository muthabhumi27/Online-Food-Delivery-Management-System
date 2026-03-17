-- ============================================================
--  FoodRush Pune — Expanded Database
--  History  : January & February 2026
--  This Month: March 2026 (Q4 active customers & Q5 delivery)
--  10 Customers, 85 Orders, Rich data for all 5 queries
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
--  CUSTOMERS  (10 customers)
-- ─────────────────────────────────────────
INSERT INTO Customer (CustomerName, CustomerEmail, Phone) VALUES
('Aarav Sharma',   'aarav@gmail.com',  '9876501001'),
('Priya Desai',    'priya@gmail.com',  '9876501002'),
('Rohan Kulkarni', 'rohan@gmail.com',  '9876501003'),
('Sneha Joshi',    'sneha@gmail.com',  '9876501004'),
('Arjun Mehta',    'arjun@gmail.com',  '9876501005'),
('Kavya Nair',     'kavya@gmail.com',  '9876501006'),
('Vikram Patil',   'vikram@gmail.com', '9876501007'),
('Ananya Iyer',    'ananya@gmail.com', '9876501008'),
('Rahul Chavan',   'rahul@gmail.com',  '9876501009'),
('Pooja Marathe',  'pooja@gmail.com',  '9876501010');

-- ─────────────────────────────────────────
--  ADDRESSES
-- ─────────────────────────────────────────
INSERT INTO Address (Street, City, Pincode, CustomerID) VALUES
('301 Sunrise Apts, FC Road',         'Pune', '411004', 1),
('B-12 Koregaon Park',                'Pune', '411001', 2),
('22 Deccan Gymkhana',                'Pune', '411004', 3),
('45 Baner Road',                     'Pune', '411045', 4),
('8A Aundh ITI Road',                 'Pune', '411007', 5),
('7th Floor, Rajiv Gandhi IT Park',   'Pune', '411057', 1),
('Hostel Block C, Symbiosis',         'Pune', '411004', 3),
('Infosys Campus Gate 4, Hinjewadi',  'Pune', '411057', 5),
('14 Viman Nagar, Near Phoenix Mall', 'Pune', '411014', 6),
('88 Kothrud, Behind Westend Mall',   'Pune', '411038', 7),
('C-5 Wakad, Hinjewadi Road',         'Pune', '411057', 8),
('Plot 12, Hadapsar, Magarpatta',      'Pune', '411013', 9),
('33 Kharadi, EON IT Park Road',      'Pune', '411014', 10);

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
('Bun Maska',            40,  1, 1),
('Brun Maska',           45,  1, 1),
('Egg Half Fry',         55,  1, 1),
('Chicken Sandwich',    120,  1, 1),
('Special Irani Chai',   30,  1, 1),
('Cold Coffee',          70,  1, 1),
('Lassi',                60,  1, 1),
('Shrewsbury Biscuits', 180,  1, 2),
('Mawa Cake',            65,  1, 2),
('Khari Biscuit',        90,  1, 2),
('Wine Biscuits',       120,  1, 2),
('Cream Roll',           55,  1, 2),
('Plum Cake',            85,  1, 2),
('Thai Green Curry',    380,  1, 3),
('Pad Thai Noodles',    320,  1, 3),
('Tom Yum Soup',        240,  1, 3),
('Sushi Platter 8pcs',  520,  1, 3),
('Kimchi Fried Rice',   290,  1, 3),
('Ramen Bowl',          340,  1, 3),
('Dal Makhani',         220,  1, 4),
('Paneer Butter Masala',280,  1, 4),
('Sarson Ka Saag',      240,  1, 4),
('Tandoori Roti',        35,  1, 4),
('Butter Naan',          55,  1, 4),
('Chicken Biryani',     320,  1, 4),
('Seekh Kebab 4pcs',    280,  0, 4),
('Classic Choco Waffle',180,  1, 5),
('Strawberry Sensation',200,  1, 5),
('Nutella Overload',    220,  1, 5),
('Lotus Biscoff',       240,  1, 5),
('Oreo Milkshake',      150,  1, 5),
('Mango Smoothie',      130,  1, 5),
('Chicken Berry Pulao', 340,  1, 6),
('Mutton Dhansak',      380,  1, 6),
('Akuri on Toast',      160,  1, 6),
('Cheese Omelette',     120,  1, 6),
('Irani Chai',           30,  0, 6),
('Caramel Custard',      80,  1, 6);

-- ─────────────────────────────────────────
--  ORDERS
--  Jan 2026  : 1–30  (all 7 weekdays covered for Q2 heatmap)
--  Feb 2026  : 31–60 (Q4 filter range)
--  Mar 2026  : 61–85 (Q4 active customers + Q5 delivery)
-- ─────────────────────────────────────────
INSERT INTO `Order` (OrderDate, OrderStatus, CustomerID, RestaurantID) VALUES
-- ══ January 2026 ══
('2026-01-05', 'Delivered',  3, 3),  -- 1  Mon
('2026-01-06', 'Delivered',  5, 1),  -- 2  Tue
('2026-01-07', 'Delivered',  1, 2),  -- 3  Wed
('2026-01-08', 'Delivered',  6, 4),  -- 4  Thu
('2026-01-09', 'Delivered',  3, 6),  -- 5  Fri
('2026-01-10', 'Delivered',  7, 3),  -- 6  Sat
('2026-01-11', 'Delivered',  2, 5),  -- 7  Sun
('2026-01-12', 'Delivered',  8, 3),  -- 8  Mon
('2026-01-13', 'Delivered',  4, 1),  -- 9  Tue
('2026-01-14', 'Delivered',  9, 6),  -- 10 Wed
('2026-01-15', 'Delivered',  3, 3),  -- 11 Thu
('2026-01-16', 'Delivered',  5, 2),  -- 12 Fri
('2026-01-17', 'Delivered', 10, 4),  -- 13 Sat
('2026-01-18', 'Delivered',  1, 3),  -- 14 Sun
('2026-01-19', 'Delivered',  6, 6),  -- 15 Mon
('2026-01-20', 'Delivered',  7, 1),  -- 16 Tue
('2026-01-21', 'Delivered',  3, 3),  -- 17 Wed
('2026-01-22', 'Delivered',  8, 5),  -- 18 Thu
('2026-01-23', 'Delivered',  2, 3),  -- 19 Fri
('2026-01-24', 'Delivered',  9, 2),  -- 20 Sat
('2026-01-25', 'Delivered',  4, 6),  -- 21 Sun
('2026-01-26', 'Cancelled',  5, 1),  -- 22 Mon cancelled
('2026-01-27', 'Delivered', 10, 3),  -- 23 Tue
('2026-01-28', 'Delivered',  1, 4),  -- 24 Wed
('2026-01-29', 'Delivered',  6, 3),  -- 25 Thu
('2026-01-30', 'Delivered',  3, 6),  -- 26 Fri
('2026-01-31', 'Delivered',  7, 2),  -- 27 Sat
('2026-01-11', 'Delivered',  5, 3),  -- 28 Sun
('2026-01-18', 'Delivered',  2, 3),  -- 29 Sun
('2026-01-25', 'Delivered',  8, 6),  -- 30 Sun
-- ══ February 2026 ══
('2026-02-02', 'Delivered',  3, 3),  -- 31 Mon
('2026-02-03', 'Delivered',  5, 1),  -- 32 Tue
('2026-02-04', 'Delivered',  1, 2),  -- 33 Wed
('2026-02-05', 'Delivered',  6, 4),  -- 34 Thu
('2026-02-06', 'Delivered',  3, 6),  -- 35 Fri
('2026-02-07', 'Delivered',  7, 3),  -- 36 Sat
('2026-02-08', 'Delivered',  2, 5),  -- 37 Sun
('2026-02-09', 'Delivered',  8, 3),  -- 38 Mon
('2026-02-10', 'Delivered',  4, 1),  -- 39 Tue
('2026-02-11', 'Delivered',  9, 6),  -- 40 Wed
('2026-02-12', 'Delivered',  3, 3),  -- 41 Thu
('2026-02-13', 'Delivered',  5, 2),  -- 42 Fri
('2026-02-14', 'Delivered', 10, 3),  -- 43 Sat
('2026-02-15', 'Delivered',  1, 6),  -- 44 Sun
('2026-02-16', 'Delivered',  6, 3),  -- 45 Mon
('2026-02-17', 'Delivered',  7, 1),  -- 46 Tue
('2026-02-18', 'Delivered',  3, 5),  -- 47 Wed
('2026-02-19', 'Delivered',  8, 3),  -- 48 Thu
('2026-02-20', 'Delivered',  2, 6),  -- 49 Fri
('2026-02-21', 'Delivered',  9, 2),  -- 50 Sat
('2026-02-22', 'Delivered',  4, 3),  -- 51 Sun
('2026-02-23', 'Delivered', 10, 4),  -- 52 Mon
('2026-02-24', 'Cancelled',  5, 1),  -- 53 Tue cancelled
('2026-02-25', 'Delivered',  1, 3),  -- 54 Wed
('2026-02-26', 'Delivered',  6, 6),  -- 55 Thu
('2026-02-27', 'Delivered',  3, 2),  -- 56 Fri
('2026-02-28', 'Delivered',  7, 3),  -- 57 Sat
('2026-02-08', 'Delivered',  3, 3),  -- 58 Sun
('2026-02-15', 'Delivered',  5, 6),  -- 59 Sun
('2026-02-14', 'Placed',     2, 4),  -- 60 Unavailable item, no payment → Q3
-- ══ March 2026 current month ══
(DATE_SUB(CURDATE(), INTERVAL  1 DAY), 'Delivered',  3, 3),  -- 61
(DATE_SUB(CURDATE(), INTERVAL  4 DAY), 'Delivered',  3, 6),  -- 62
(DATE_SUB(CURDATE(), INTERVAL  7 DAY), 'Delivered',  3, 3),  -- 63
(DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Delivered',  3, 1),  -- 64
(DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Delivered',  3, 2),  -- 65
(DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'Delivered',  3, 3),  -- 66
(DATE_SUB(CURDATE(), INTERVAL  2 DAY), 'Delivered',  5, 3),  -- 67
(DATE_SUB(CURDATE(), INTERVAL  5 DAY), 'Delivered',  5, 6),  -- 68
(DATE_SUB(CURDATE(), INTERVAL  9 DAY), 'Delivered',  5, 3),  -- 69
(DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Delivered',  5, 1),  -- 70
(DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Delivered',  5, 3),  -- 71
(DATE_SUB(CURDATE(), INTERVAL  3 DAY), 'Delivered',  6, 4),  -- 72
(DATE_SUB(CURDATE(), INTERVAL  8 DAY), 'Delivered',  6, 6),  -- 73
(DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered',  6, 3),  -- 74
(DATE_SUB(CURDATE(), INTERVAL 17 DAY), 'Delivered',  6, 2),  -- 75
(DATE_SUB(CURDATE(), INTERVAL  3 DAY), 'Delivered',  1, 2),  -- 76
(DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Delivered',  1, 3),  -- 77
(DATE_SUB(CURDATE(), INTERVAL 19 DAY), 'Delivered',  1, 6),  -- 78
(DATE_SUB(CURDATE(), INTERVAL  5 DAY), 'Delivered',  7, 3),  -- 79
(DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered',  7, 5),  -- 80
(DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Delivered',  7, 1),  -- 81
(DATE_SUB(CURDATE(), INTERVAL  6 DAY), 'Delivered',  2, 4),  -- 82
(DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'Delivered',  2, 3),  -- 83
(DATE_SUB(CURDATE(), INTERVAL  8 DAY), 'Delivered',  4, 5),  -- 84
(DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Delivered',  8, 6);  -- 85

-- ─────────────────────────────────────────
--  ORDER ITEMS
-- ─────────────────────────────────────────
INSERT INTO OrderItem (OrderID, FoodItemID, Quantity, ItemPrice) VALUES
-- January
(1,  14, 4, 380), (1,  15, 3, 320),
(2,   1, 3,  40), (2,   5, 4,  30),
(3,   8, 3, 180), (3,   9, 2,  65),
(4,  20, 2, 220), (4,  26, 1, 320),
(5,  33, 2, 340), (5,  36, 3,  80),
(6,  14, 5, 380), (6,  17, 2, 520),
(7,  27, 3, 180), (7,  31, 2, 150),
(8,  14, 4, 380), (8,  18, 2, 290),
(9,   1, 4,  40), (9,   5, 5,  30),
(10, 33, 3, 340), (10, 34, 2, 380),
(11, 14, 5, 380), (11, 15, 4, 320),
(12,  8, 3, 180), (12, 12, 2,  55),
(13, 20, 2, 220), (13, 24, 3,  35),
(14, 14, 3, 380), (14, 16, 2, 240),
(15, 33, 2, 340), (15, 35, 3, 160),
(16,  1, 3,  40), (16,  6, 2,  70),
(17, 14, 5, 380), (17, 15, 4, 320),
(18, 27, 2, 180), (18, 30, 2, 240),
(19, 14, 4, 380), (19, 18, 3, 290),
(20,  8, 2, 180), (20, 10, 2,  90),
(21, 33, 3, 340), (21, 38, 2,  80),
(22,  1, 2,  40), (22,  5, 1,  30),
(23, 14, 4, 380), (23, 15, 3, 320),
(24, 20, 2, 220), (24, 26, 1, 320),
(25, 14, 4, 380), (25, 18, 2, 290),
(26, 33, 2, 340), (26, 34, 2, 380),
(27,  8, 3, 180), (27, 13, 1,  85),
(28, 14, 3, 380), (28, 15, 2, 320),
(29, 14, 4, 380), (29, 16, 3, 240),
(30, 33, 2, 340), (30, 36, 2,  80),
-- February
(31, 14, 4, 380), (31, 15, 3, 320),
(32,  1, 3,  40), (32,  5, 4,  30),
(33,  8, 3, 180), (33,  9, 2,  65),
(34, 20, 2, 220), (34, 25, 2,  55),
(35, 33, 3, 340), (35, 36, 2,  80),
(36, 14, 5, 380), (36, 17, 2, 520),
(37, 27, 3, 180), (37, 31, 2, 150),
(38, 14, 4, 380), (38, 18, 2, 290),
(39,  1, 4,  40), (39,  5, 5,  30),
(40, 33, 3, 340), (40, 35, 2, 160),
(41, 14, 5, 380), (41, 15, 4, 320),
(42,  8, 3, 180), (42, 12, 2,  55),
(43, 14, 4, 380), (43, 16, 2, 240),
(44, 33, 2, 340), (44, 34, 2, 380),
(45, 14, 4, 380), (45, 15, 3, 320),
(46,  1, 3,  40), (46,  4, 2, 120),
(47, 27, 3, 180), (47, 29, 2, 220),
(48, 14, 5, 380), (48, 18, 3, 290),
(49, 33, 3, 340), (49, 38, 2,  80),
(50,  8, 2, 180), (50, 10, 2,  90),
(51, 14, 4, 380), (51, 15, 3, 320),
(52, 20, 2, 220), (52, 26, 1, 320),
(53,  1, 2,  40), (53,  5, 1,  30),
(54, 14, 4, 380), (54, 16, 2, 240),
(55, 33, 2, 340), (55, 35, 3, 160),
(56,  8, 3, 180), (56, 13, 1,  85),
(57, 14, 5, 380), (57, 15, 4, 320),
(58, 14, 4, 380), (58, 18, 2, 290),
(59, 33, 3, 340), (59, 36, 2,  80),
(60, 27, 2, 280),  -- Seekh Kebab unavailable → Q3
-- March
(61, 14, 3, 380), (61, 15, 2, 320),
(62, 33, 2, 340), (62, 35, 2, 160),
(63, 14, 4, 380), (63, 18, 2, 290),
(64,  1, 4,  40), (64,  5, 3,  30),
(65,  8, 3, 180), (65,  9, 2,  65),
(66, 14, 5, 380), (66, 15, 4, 320),
(67, 14, 3, 380), (67, 16, 2, 240),
(68, 33, 2, 340), (68, 36, 2,  80),
(69, 14, 4, 380), (69, 15, 3, 320),
(70,  1, 3,  40), (70,  5, 4,  30),
(71, 14, 5, 380), (71, 18, 3, 290),
(72, 20, 2, 220), (72, 26, 1, 320),
(73, 33, 2, 340), (73, 35, 2, 160),
(74, 14, 3, 380), (74, 16, 1, 240),
(75,  8, 2, 180), (75, 13, 1,  85),
(76,  8, 3, 180), (76,  9, 2,  65),
(77, 14, 2, 380), (77, 15, 1, 320),
(78, 33, 2, 340), (78, 34, 2, 380),
(79, 14, 4, 380), (79, 17, 2, 520),
(80, 27, 2, 180), (80, 31, 1, 150),
(81,  1, 3,  40), (81,  6, 2,  70),
(82, 20, 2, 220), (82, 25, 2,  55),
(83, 14, 3, 380), (83, 15, 2, 320),
(84, 27, 2, 180), (84, 29, 2, 220),
(85, 33, 2, 340), (85, 36, 2,  80);

-- ─────────────────────────────────────────
--  PAYMENTS
--  Order 60 → NO payment row (NOT EXISTS fires for Q3)
-- ─────────────────────────────────────────
INSERT INTO Payment (PaymentMethod, PaymentStatus, PaymentDate, OrderID) VALUES
('UPI',    'Paid',    '2026-01-05',  1), ('Card',   'Paid',    '2026-01-06',  2),
('UPI',    'Paid',    '2026-01-07',  3), ('Cash',   'Pending', '2026-01-08',  4),
('Wallet', 'Paid',    '2026-01-09',  5), ('UPI',    'Paid',    '2026-01-10',  6),
('Card',   'Paid',    '2026-01-11',  7), ('UPI',    'Paid',    '2026-01-12',  8),
('UPI',    'Paid',    '2026-01-13',  9), ('Wallet', 'Paid',    '2026-01-14', 10),
('Card',   'Paid',    '2026-01-15', 11), ('UPI',    'Paid',    '2026-01-16', 12),
('Cash',   'Pending', '2026-01-17', 13), ('UPI',    'Paid',    '2026-01-18', 14),
('UPI',    'Paid',    '2026-01-19', 15), ('Card',   'Paid',    '2026-01-20', 16),
('UPI',    'Paid',    '2026-01-21', 17), ('Wallet', 'Paid',    '2026-01-22', 18),
('UPI',    'Paid',    '2026-01-23', 19), ('Card',   'Paid',    '2026-01-24', 20),
('UPI',    'Paid',    '2026-01-25', 21), ('UPI',    'Failed',  '2026-01-26', 22),
('UPI',    'Paid',    '2026-01-27', 23), ('Cash',   'Pending', '2026-01-28', 24),
('UPI',    'Paid',    '2026-01-29', 25), ('Card',   'Paid',    '2026-01-30', 26),
('UPI',    'Paid',    '2026-01-31', 27), ('Wallet', 'Paid',    '2026-01-11', 28),
('UPI',    'Paid',    '2026-01-18', 29), ('Card',   'Paid',    '2026-01-25', 30),
('UPI',    'Paid',    '2026-02-02', 31), ('Card',   'Paid',    '2026-02-03', 32),
('UPI',    'Paid',    '2026-02-04', 33), ('Wallet', 'Paid',    '2026-02-05', 34),
('UPI',    'Paid',    '2026-02-06', 35), ('Card',   'Paid',    '2026-02-07', 36),
('UPI',    'Paid',    '2026-02-08', 37), ('Cash',   'Pending', '2026-02-09', 38),
('UPI',    'Paid',    '2026-02-10', 39), ('Wallet', 'Paid',    '2026-02-11', 40),
('Card',   'Paid',    '2026-02-12', 41), ('UPI',    'Paid',    '2026-02-13', 42),
('UPI',    'Paid',    '2026-02-14', 43), ('Card',   'Paid',    '2026-02-15', 44),
('UPI',    'Paid',    '2026-02-16', 45), ('Wallet', 'Paid',    '2026-02-17', 46),
('UPI',    'Paid',    '2026-02-18', 47), ('UPI',    'Paid',    '2026-02-19', 48),
('Card',   'Paid',    '2026-02-20', 49), ('UPI',    'Paid',    '2026-02-21', 50),
('UPI',    'Paid',    '2026-02-22', 51), ('Cash',   'Pending', '2026-02-23', 52),
('UPI',    'Failed',  '2026-02-24', 53), ('Wallet', 'Paid',    '2026-02-25', 54),
('UPI',    'Paid',    '2026-02-26', 55), ('Card',   'Paid',    '2026-02-27', 56),
('UPI',    'Paid',    '2026-02-28', 57), ('UPI',    'Paid',    '2026-02-08', 58),
('Card',   'Paid',    '2026-02-15', 59),
-- Order 60 → NO payment (NOT EXISTS fires for Q3)
('UPI',    'Paid',    CURDATE(), 61), ('Card',   'Paid',    CURDATE(), 62),
('UPI',    'Paid',    CURDATE(), 63), ('Wallet', 'Paid',    CURDATE(), 64),
('UPI',    'Paid',    CURDATE(), 65), ('UPI',    'Paid',    CURDATE(), 66),
('Card',   'Paid',    CURDATE(), 67), ('UPI',    'Paid',    CURDATE(), 68),
('UPI',    'Paid',    CURDATE(), 69), ('Wallet', 'Paid',    CURDATE(), 70),
('UPI',    'Paid',    CURDATE(), 71), ('Cash',   'Pending', CURDATE(), 72),
('UPI',    'Paid',    CURDATE(), 73), ('Card',   'Paid',    CURDATE(), 74),
('UPI',    'Paid',    CURDATE(), 75), ('UPI',    'Paid',    CURDATE(), 76),
('Wallet', 'Paid',    CURDATE(), 77), ('Card',   'Paid',    CURDATE(), 78),
('UPI',    'Paid',    CURDATE(), 79), ('UPI',    'Paid',    CURDATE(), 80),
('Cash',   'Pending', CURDATE(), 81), ('UPI',    'Paid',    CURDATE(), 82),
('Card',   'Paid',    CURDATE(), 83), ('UPI',    'Paid',    CURDATE(), 84),
('Wallet', 'Paid',    CURDATE(), 85);

-- ─────────────────────────────────────────
--  DELIVERY PARTNERS  (March orders, Q5)
--  Sanjay = 6 deliveries → clear #1
-- ─────────────────────────────────────────
INSERT INTO DeliveryPartner (Name, Phone, VehicleType, OrderID) VALUES
('Sanjay Patil',  '9876541001', 'Bike',    61),
('Rahul Shinde',  '9876541002', 'Scooter', 62),
('Amit Waghmare', '9876541003', 'Bike',    63),
('Ganesh Jadhav', '9876541004', 'Scooter', 64),
('Vijay Kale',    '9876541005', 'Bike',    65),
('Sanjay Patil',  '9876541001', 'Bike',    66),
('Rahul Shinde',  '9876541002', 'Scooter', 67),
('Amit Waghmare', '9876541003', 'Bike',    68),
('Sanjay Patil',  '9876541001', 'Bike',    69),
('Ganesh Jadhav', '9876541004', 'Scooter', 70),
('Rahul Shinde',  '9876541002', 'Scooter', 71),
('Vijay Kale',    '9876541005', 'Bike',    72),
('Sanjay Patil',  '9876541001', 'Bike',    73),
('Amit Waghmare', '9876541003', 'Bike',    74),
('Ganesh Jadhav', '9876541004', 'Scooter', 75),
('Vijay Kale',    '9876541005', 'Bike',    76),
('Sanjay Patil',  '9876541001', 'Bike',    77),
('Rahul Shinde',  '9876541002', 'Scooter', 78),
('Amit Waghmare', '9876541003', 'Bike',    79),
('Ganesh Jadhav', '9876541004', 'Scooter', 80),
('Vijay Kale',    '9876541005', 'Bike',    81),
('Rahul Shinde',  '9876541002', 'Scooter', 82),
('Sanjay Patil',  '9876541001', 'Bike',    83),
('Amit Waghmare', '9876541003', 'Bike',    84),
('Ganesh Jadhav', '9876541004', 'Scooter', 85);

-- ─────────────────────────────────────────
--  REVIEWS  (8–10 per restaurant for Q1)
-- ─────────────────────────────────────────
INSERT INTO Review (Rating, Comment, ReviewDate, CustomerID, RestaurantID) VALUES
-- Vohuman Café (8)
(5.0, 'Best Irani chai in Pune!',         '2026-01-10', 1, 1),
(4.5, 'Bun Maska every morning',          '2026-01-15', 2, 1),
(4.8, 'Authentic old Pune vibe',          '2026-01-20', 3, 1),
(4.7, 'Classic breakfast spot',           '2026-02-07', 5, 1),
(4.6, 'Simple and consistently great',   '2026-02-12', 4, 1),
(5.0, 'Best chai, period.',               '2026-02-18', 6, 1),
(4.9, 'Never disappoints',               '2026-02-22', 7, 1),
(4.8, 'Egg half fry is underrated',       '2026-02-25', 8, 1),
-- Kayani Bakery (8)
(4.9, 'Shrewsbury biscuits legendary',   '2026-01-08', 2, 2),
(5.0, 'Mawa cake is divine',             '2026-01-14', 4, 2),
(4.8, 'Kayani never disappoints',        '2026-01-20', 3, 2),
(4.7, 'Worth the queue every time',      '2026-02-04', 1, 2),
(4.6, 'Cream rolls fresh daily',         '2026-02-10', 5, 2),
(4.9, 'Iconic Pune institution',         '2026-02-17', 9, 2),
(4.8, 'Plum cake was rich',              '2026-02-23', 10, 2),
(4.7, 'Khari biscuits addictive',        '2026-02-27', 6, 2),
-- Malaka Spice (10 — highest rated, clear Q1 winner)
(5.0, 'Pad Thai absolutely perfect',     '2026-01-06', 3, 3),
(4.9, 'Tom Yum soup incredible',         '2026-01-11', 5, 3),
(4.8, 'Sushi was super fresh',           '2026-01-18', 1, 3),
(4.9, 'Amazing KP ambiance',             '2026-01-23', 7, 3),
(5.0, 'Best Pan-Asian in Pune',          '2026-02-02', 4, 3),
(4.8, 'Kimchi fried rice addictive',     '2026-02-09', 8, 3),
(5.0, 'Thai green curry top notch',      '2026-02-14', 5, 3),
(4.9, 'Ramen bowl was comforting',       '2026-02-19', 2, 3),
(5.0, 'Best restaurant in Pune',         '2026-02-25', 3, 3),
(4.8, 'Every visit is worth it',         '2026-02-28', 9, 3),
-- Rangla Punjab (8)
(4.2, 'Dal Makhani very creamy',         '2026-01-09', 4, 4),
(4.3, 'Good dhaba vibes',                '2026-01-15', 1, 4),
(4.0, 'Value for money',                 '2026-01-22', 5, 4),
(4.1, 'Chicken biryani was good',        '2026-02-05', 2, 4),
(4.4, 'Butter naan was fluffy',          '2026-02-11', 6, 4),
(4.2, 'Will visit again',               '2026-02-18', 10, 4),
(4.3, 'Sarson ka saag authentic',        '2026-02-24', 7, 4),
(4.0, 'Seekh kebab was spicy',           '2026-02-27', 3, 4),
-- Belgian Waffle Co. (8)
(4.0, 'Nutella waffle was rich',         '2026-01-11', 5, 5),
(4.2, 'Worth every rupee',               '2026-01-17', 2, 5),
(4.3, 'Lotus Biscoff waffle amazing',    '2026-01-24', 8, 5),
(4.1, 'Oreo milkshake was thick',        '2026-02-03', 3, 5),
(4.0, 'Nice FC Road spot',               '2026-02-10', 4, 5),
(4.2, 'Great dessert place',             '2026-02-16', 9, 5),
(4.3, 'Mango smoothie was fresh',        '2026-02-22', 6, 5),
(4.1, 'Strawberry waffle was sweet',     '2026-02-26', 10, 5),
-- Café Goodluck (9)
(4.8, 'Berry Pulao is iconic',           '2026-01-10', 1, 6),
(4.7, 'Mutton Dhansak wow',              '2026-01-16', 3, 6),
(4.6, 'Irani chai great as always',      '2026-01-22', 5, 6),
(4.9, 'Best Parsi food in the city',     '2026-02-03', 2, 6),
(5.0, 'Akuri on toast is perfect',       '2026-02-09', 4, 6),
(4.8, 'Always open, always good',        '2026-02-15', 7, 6),
(4.7, 'Cheese omelette was fluffy',      '2026-02-20', 8, 6),
(4.9, 'Historic place, great food',      '2026-02-25', 9, 6),
(4.8, 'Caramel custard divine',          '2026-02-28', 10, 6);

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
SELECT '✅ Database ready! 85 orders · 10 customers · 6 restaurants' AS Status;

SELECT '═══ Q1: Top 3 Restaurants ═══' AS '';
SELECT r.RestaurantName,
       ROUND(AVG(rev.Rating), 1)            AS AvgRating,
       SUM(oi.Quantity * oi.ItemPrice)       AS TotalRevenue
FROM Restaurant r
JOIN Review    rev ON r.RestaurantID = rev.RestaurantID
JOIN `Order`   o   ON r.RestaurantID = o.RestaurantID
JOIN OrderItem oi  ON o.OrderID      = oi.OrderID
GROUP BY r.RestaurantID, r.RestaurantName
HAVING COUNT(o.OrderID) > 5
ORDER BY AvgRating DESC, TotalRevenue DESC
LIMIT 3;

SELECT '═══ Q2: Restaurant Peak Days Heatmap ═══' AS '';
SELECT r.RestaurantName,
       DAYNAME(o.OrderDate)            AS DayOfWeek,
       COUNT(o.OrderID)                AS TotalOrders
FROM Restaurant r
JOIN `Order`   o  ON r.RestaurantID = o.RestaurantID
JOIN OrderItem oi ON o.OrderID      = oi.OrderID
WHERE o.OrderStatus != 'Cancelled'
GROUP BY r.RestaurantID, r.RestaurantName, DAYNAME(o.OrderDate), DAYOFWEEK(o.OrderDate)
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

SELECT '═══ Q4: Active Customers — February 2026 ═══' AS '';
SELECT c.CustomerName,
       COUNT(o.OrderID)                             AS OrdersThisMonth,
       SUM(oi.Quantity * oi.ItemPrice)              AS MonthlySpend,
       DATE_FORMAT(MAX(o.OrderDate), '%d %b %Y')    AS LastOrderDate
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