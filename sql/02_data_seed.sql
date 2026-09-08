-- =============================================================================
-- Mumbai Public Transit & Smart Mobility Network
-- Script 02: Synthetic Data Seeding & Data Manipulation (DML)
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

USE mumbai_transit_db;

-- 1. Insert Stations
INSERT INTO stations VALUES 
(101, 'Andheri', 'West', 'Metro'),
(102, 'Dadar', 'Central', 'Metro'),
(103, 'Borivali', 'North', 'Metro'),
(104, 'Bandra', 'West', 'Bus'),
(105, 'Thane', 'East', 'Bus'),
(106, 'Kurla', 'Central', 'Metro');

-- 2. Insert Routes
INSERT INTO routes VALUES 
(201, 101, 102, 18.00, 'Metro'),
(202, 103, 102, 22.00, 'Metro'),
(203, 104, 105, 15.00, 'Bus'),
(204, 105, 101, 20.00, 'Bus');

-- 3. Insert Vehicles
INSERT INTO vehicles VALUES 
(401, 'Metro Train', 800, 2018),
(402, 'Electric Bus', 50, 2020),
(403, 'Electric Bus', 45, 2021);

-- 4. Insert Commuters
INSERT INTO commuters VALUES 
(1, 'Rohit Malhotra', 29, 'M', 'North', 'Monthly Pass'),
(2, 'Ananya Iyer', 34, 'F', 'Central', 'Pay Per Ride'),
(3, 'Kunal Shah', 22, 'M', 'West', 'Student Pass'),
(4, 'Meera Joshi', 41, 'F', 'East', 'Monthly Pass'),
(5, 'Arvind Patel', 55, 'M', 'South', 'Monthly Pass'),
(6, 'Priya Sharma', 27, 'F', 'North', 'Monthly Pass'),
(7, 'Rahul Verma', 31, 'M', 'Central', 'Pay Per Ride'),
(8, 'Sneha Deshmukh', 24, 'F', 'West', 'Student Pass'),
(9, 'Amit Kulkarni', 38, 'M', 'East', 'Monthly Pass'),
(10, 'Divya Nair', 45, 'F', 'South', 'Monthly Pass'),
(11, 'Vikram Singh', 62, 'M', 'North', 'Senior Citizen'),
(12, 'Pooja Reddy', 20, 'F', 'Central', 'Student Pass'),
(13, 'Sanjay Gupta', 33, 'M', 'West', 'Pay Per Ride'),
(14, 'Kavita Menon', 28, 'F', 'East', 'Monthly Pass'),
(15, 'Rajesh Tiwari', 50, 'M', 'South', 'Pay Per Ride'),
(16, 'Nisha Agarwal', 23, 'F', 'North', 'Student Pass'),
(17, 'Deepak Jain', 36, 'M', 'Central', 'Monthly Pass'),
(18, 'Asha Pillai', 67, 'F', 'West', 'Senior Citizen'),
(19, 'Manoj Pandey', 42, 'M', 'East', 'Pay Per Ride'),
(20, 'Ritu Saxena', 29, 'F', 'South', 'Monthly Pass'),
(21, 'Suresh Yadav', 58, 'M', 'North', 'Senior Citizen'),
(22, 'Anjali Bhatt', 26, 'F', 'Central', 'Student Pass'),
(23, 'Kiran More', 35, 'M', 'West', 'Pay Per Ride'),
(24, 'Tanvi Kapoor', 19, 'F', 'East', 'Student Pass'),
(25, 'Hemant Mishra', 44, 'M', 'South', 'Monthly Pass');

-- 5. Insert Route Assignments
INSERT INTO route_assignment VALUES 
(501, 201, 401),
(502, 202, 401),
(503, 203, 402),
(504, 204, 403);

-- 6. Insert Maintenance Records
INSERT INTO maintenance VALUES 
(601, 401, '2023-05-20', 12000.00, 'Brake Check'),
(602, 402, '2023-05-22', 5000.00, 'Battery Replacement'),
(603, 403, '2023-05-25', 3000.00, 'General Service');

-- 7. Insert Trips
INSERT INTO trips VALUES 
(301, 1, 201, '2023-06-01', '08:10:00', '08:45:00', 40.00),
(302, 2, 202, '2023-06-01', '09:00:00', '09:50:00', 50.00),
(303, 3, 203, '2023-06-01', '10:15:00', '10:45:00', 20.00),
(304, 4, 204, '2023-06-02', '07:30:00', '08:10:00', 30.00),
(305, 5, 201, '2023-06-02', '11:00:00', '11:40:00', 40.00);

-- DML Updates: Fleet capacity expansion & Concession card assignment
SET SQL_SAFE_UPDATES = 0;

UPDATE vehicles
SET capacity = ROUND(capacity * 1.10);

UPDATE commuters
SET card_type = 'Senior Citizen'
WHERE age >= 60;

SET SQL_SAFE_UPDATES = 1;
