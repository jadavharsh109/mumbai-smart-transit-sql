-- =============================================================================
-- Mumbai Public Transit & Smart Mobility Network
-- Script 03: Reusable Business Intelligence Views
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

USE mumbai_transit_db;

-- -----------------------------------------------------------------------------
-- View 1: vw_commuter_profile
-- Aggregates lifetime trips and cumulative fare spend per commuter
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_commuter_profile AS
SELECT 
    c.commuter_id,
    c.commuter_name,
    c.card_type,
    c.city_zone,
    COUNT(t.trip_id) AS total_trips,
    COALESCE(SUM(t.fare), 0) AS total_fare_spent,
    COALESCE(ROUND(AVG(t.fare), 2), 0) AS avg_fare_per_trip
FROM commuters c
LEFT JOIN trips t ON c.commuter_id = t.commuter_id
GROUP BY c.commuter_id, c.commuter_name, c.card_type, c.city_zone;

-- -----------------------------------------------------------------------------
-- View 2: vw_route_performance
-- Monitors trip volume, rider revenue, and route details
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_route_performance AS
SELECT 
    r.route_id,
    r.route_type,
    s1.station_name AS source_station,
    s2.station_name AS destination_station,
    r.distance_km,
    COUNT(t.trip_id) AS total_trips,
    COALESCE(SUM(t.fare), 0) AS total_route_revenue,
    ROUND(COALESCE(SUM(t.fare), 0) / r.distance_km, 2) AS revenue_per_km
FROM routes r
JOIN stations s1 ON r.source_station = s1.station_id
JOIN stations s2 ON r.destination_station = s2.station_id
LEFT JOIN trips t ON r.route_id = t.route_id
GROUP BY r.route_id, r.route_type, s1.station_name, s2.station_name, r.distance_km;

-- -----------------------------------------------------------------------------
-- View 3: vw_vehicle_fleet_health
-- Tracks maintenance spend relative to vehicle seating capacity
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_vehicle_fleet_health AS
SELECT 
    v.vehicle_id,
    v.vehicle_type,
    v.capacity,
    v.manufacture_year,
    COALESCE(SUM(m.cost), 0) AS total_maintenance_expenditure,
    ROUND(COALESCE(SUM(m.cost), 0) / v.capacity, 2) AS maintenance_cost_per_seat
FROM vehicles v
LEFT JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_type, v.capacity, v.manufacture_year;
