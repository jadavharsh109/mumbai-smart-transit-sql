-- =============================================================================
-- Mumbai Public Transit & Smart Mobility Network
-- Script 04: Advanced Operational Analytics, KPIs & Window Functions
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

USE mumbai_transit_db;

-- =============================================================================
-- SECTION 1: Transit Network & Route Performance
-- =============================================================================

-- Q1. Overview of Metro vs Bus stations
SELECT station_type, COUNT(*) AS station_count
FROM stations
GROUP BY station_type;

-- Q2. Total daily fare collection across all trips
SELECT 
    trip_date, 
    COUNT(trip_id) AS total_daily_trips,
    ROUND(SUM(fare), 2) AS daily_revenue,
    ROUND(AVG(fare), 2) AS avg_fare_per_trip
FROM trips
GROUP BY trip_date
ORDER BY trip_date;

-- Q3. Average travel duration across all completed trips
SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, start_time, end_time)), 2) AS avg_trip_duration_mins
FROM trips;

-- Q4. Top revenue-generating transit route
SELECT 
    r.route_id, 
    r.route_type,
    s1.station_name AS source_station,
    s2.station_name AS destination_station,
    SUM(t.fare) AS total_revenue
FROM routes r
JOIN stations s1 ON r.source_station = s1.station_id
JOIN stations s2 ON r.destination_station = s2.station_id
JOIN trips t ON r.route_id = t.route_id
GROUP BY r.route_id, r.route_type, s1.station_name, s2.station_name
ORDER BY total_revenue DESC
LIMIT 1;

-- =============================================================================
-- SECTION 2: Complex Multi-Table JOINs & Fleet Assignments
-- =============================================================================

-- Q5. 4-Way Relational JOIN: Linking Trips -> Routes -> Route Assignments -> Vehicles
SELECT 
    t.trip_id,
    t.trip_date,
    t.fare,
    r.route_id,
    r.route_type,
    v.vehicle_id,
    v.vehicle_type,
    v.capacity
FROM trips t
JOIN routes r ON t.route_id = r.route_id
JOIN route_assignment ra ON r.route_id = ra.route_id
JOIN vehicles v ON ra.vehicle_id = v.vehicle_id;

-- Q6. Find unassigned vehicles (Spare fleet capacity)
SELECT v.vehicle_id, v.vehicle_type, v.capacity, v.manufacture_year
FROM vehicles v
LEFT JOIN route_assignment ra ON v.vehicle_id = ra.vehicle_id
WHERE ra.vehicle_id IS NULL;

-- =============================================================================
-- SECTION 3: Advanced Subqueries & Aggregations
-- =============================================================================

-- Q7. Routes generating revenue higher than the network average route revenue
SELECT 
    route_id, 
    SUM(fare) AS route_revenue
FROM trips
GROUP BY route_id
HAVING SUM(fare) > (
    SELECT AVG(total_fare)
    FROM (
        SELECT SUM(fare) AS total_fare
        FROM trips
        GROUP BY route_id
    ) AS route_benchmark
);

-- Q8. Commuters whose total expenditure exceeds the citywide average commuter spend
SELECT 
    c.commuter_id, 
    c.commuter_name, 
    SUM(t.fare) AS total_spent
FROM commuters c
JOIN trips t ON c.commuter_id = t.commuter_id
GROUP BY c.commuter_id, c.commuter_name
HAVING SUM(t.fare) > (
    SELECT AVG(commuter_total)
    FROM (
        SELECT SUM(fare) AS commuter_total
        FROM trips
        GROUP BY commuter_id
    ) AS commuter_benchmark
);

-- =============================================================================
-- SECTION 4: Window Functions & Segmented Rankings
-- =============================================================================

-- Q9. Rank routes by total revenue generated
SELECT 
    route_id,
    SUM(fare) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fare) DESC) AS revenue_rank
FROM trips
GROUP BY route_id;

-- Q10. Identify top 5 spending commuters using Window Functions
SELECT commuter_id, commuter_name, total_spent, spending_rank
FROM (
    SELECT 
        c.commuter_id, 
        c.commuter_name,
        SUM(t.fare) AS total_spent,
        RANK() OVER (ORDER BY SUM(t.fare) DESC) AS spending_rank
    FROM commuters c
    JOIN trips t ON c.commuter_id = t.commuter_id
    GROUP BY c.commuter_id, c.commuter_name
) AS ranked_commuters
WHERE spending_rank <= 5;

-- Q11. Rank vehicles by cumulative maintenance expenses
SELECT 
    v.vehicle_id, 
    v.vehicle_type,
    SUM(m.cost) AS total_maintenance_cost,
    RANK() OVER (ORDER BY SUM(m.cost) DESC) AS maintenance_rank
FROM vehicles v
JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_type;

-- =============================================================================
-- SECTION 5: Operational KPIs & Efficiency Benchmarks
-- =============================================================================

-- Q12. Zone with the highest revenue generation
SELECT 
    c.city_zone, 
    SUM(t.fare) AS zone_revenue
FROM commuters c
JOIN trips t ON c.commuter_id = t.commuter_id
GROUP BY c.city_zone
ORDER BY zone_revenue DESC
LIMIT 1;

-- Q13. Vehicle category with the lowest maintenance cost per seat
SELECT 
    v.vehicle_type,
    SUM(m.cost) AS total_maintenance_cost,
    AVG(v.capacity) AS avg_capacity,
    ROUND(SUM(m.cost) / AVG(v.capacity), 2) AS maintenance_cost_per_seat
FROM vehicles v
JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_type
ORDER BY maintenance_cost_per_seat ASC
LIMIT 1;

-- Q14. Vehicle utilization: Route with the highest trip-to-vehicle ratio
SELECT 
    r.route_id, 
    r.route_type,
    COUNT(DISTINCT t.trip_id) AS total_trips,
    COUNT(DISTINCT ra.vehicle_id) AS assigned_vehicles,
    ROUND(COUNT(DISTINCT t.trip_id) / COUNT(DISTINCT ra.vehicle_id), 2) AS trips_per_vehicle
FROM routes r
JOIN trips t ON r.route_id = t.route_id
JOIN route_assignment ra ON r.route_id = ra.route_id
GROUP BY r.route_id, r.route_type
ORDER BY trips_per_vehicle DESC
LIMIT 1;
