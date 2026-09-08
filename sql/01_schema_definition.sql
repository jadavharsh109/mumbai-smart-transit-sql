-- =============================================================================
-- Mumbai Public Transit & Smart Mobility Network
-- Script 01: Relational Schema Definition, Primary/Foreign Keys & Constraints
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

CREATE DATABASE IF NOT EXISTS mumbai_transit_db;
USE mumbai_transit_db;

-- -----------------------------------------------------------------------------
-- 1. Table: stations
-- Represents transit stations across Western, Central, Harbor, and Metro zones
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS route_assignment;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS stations;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS commuters;

CREATE TABLE stations (
    station_id      INT             NOT NULL,
    station_name    VARCHAR(100)    NOT NULL,
    zone            VARCHAR(50)     NOT NULL,
    station_type    VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_stations PRIMARY KEY (station_id)
);

-- -----------------------------------------------------------------------------
-- 2. Table: routes
-- Connects source and destination stations with distances and transit types
-- -----------------------------------------------------------------------------
CREATE TABLE routes (
    route_id            INT             NOT NULL,
    source_station      INT             NOT NULL,
    destination_station INT             NOT NULL,
    distance_km         DECIMAL(10,2)   NOT NULL,
    route_type          VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_routes PRIMARY KEY (route_id),
    CONSTRAINT fk_routes_source FOREIGN KEY (source_station) REFERENCES stations(station_id) ON DELETE CASCADE,
    CONSTRAINT fk_routes_dest FOREIGN KEY (destination_station) REFERENCES stations(station_id) ON DELETE CASCADE,
    CONSTRAINT chk_route_type CHECK (route_type IN ('Metro', 'Bus', 'Train'))
);

-- -----------------------------------------------------------------------------
-- 3. Table: vehicles
-- Rolling stock including Metro rakes and Electric Buses
-- -----------------------------------------------------------------------------
CREATE TABLE vehicles (
    vehicle_id          INT             NOT NULL,
    vehicle_type        VARCHAR(50)     NOT NULL,
    capacity            INT             NOT NULL,
    manufacture_year    INT             NOT NULL,
    CONSTRAINT pk_vehicles PRIMARY KEY (vehicle_id),
    CONSTRAINT chk_vehicle_capacity CHECK (capacity > 0)
);

-- -----------------------------------------------------------------------------
-- 4. Table: commuters
-- Registered commuters, demographics, city zones, and subscription cards
-- -----------------------------------------------------------------------------
CREATE TABLE commuters (
    commuter_id     INT             NOT NULL,
    commuter_name   VARCHAR(100)    NOT NULL,
    age             INT             NOT NULL,
    gender          CHAR(1)         NOT NULL,
    city_zone       VARCHAR(50)     NOT NULL,
    card_type       VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_commuters PRIMARY KEY (commuter_id),
    CONSTRAINT chk_commuter_gender CHECK (gender IN ('M', 'F', 'O'))
);

-- -----------------------------------------------------------------------------
-- 5. Table: trips
-- Commuter transit trips, fares, timestamps, and route links
-- -----------------------------------------------------------------------------
CREATE TABLE trips (
    trip_id         INT             NOT NULL,
    commuter_id     INT             NOT NULL,
    route_id        INT             NOT NULL,
    trip_date       DATE            NOT NULL,
    start_time      TIME            NOT NULL,
    end_time        TIME            NOT NULL,
    fare            DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_trips PRIMARY KEY (trip_id),
    CONSTRAINT fk_trips_commuter FOREIGN KEY (commuter_id) REFERENCES commuters(commuter_id) ON DELETE CASCADE,
    CONSTRAINT fk_trips_route FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE,
    CONSTRAINT chk_fare_positive CHECK (fare > 0)
);

CREATE INDEX idx_trip_date ON trips(trip_date);
CREATE INDEX idx_trip_route ON trips(route_id);

-- -----------------------------------------------------------------------------
-- 6. Table: route_assignment
-- Maps specific transit vehicles to designated operational routes
-- -----------------------------------------------------------------------------
CREATE TABLE route_assignment (
    assignment_id   INT NOT NULL,
    route_id        INT NOT NULL,
    vehicle_id      INT NOT NULL,
    CONSTRAINT pk_route_assignment PRIMARY KEY (assignment_id),
    CONSTRAINT fk_ra_route FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE,
    CONSTRAINT fk_ra_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 7. Table: maintenance
-- Vehicle inspection, servicing history, and operational maintenance costs
-- -----------------------------------------------------------------------------
CREATE TABLE maintenance (
    maintenance_id      INT             NOT NULL,
    vehicle_id          INT             NOT NULL,
    maintenance_date    DATE            NOT NULL,
    cost                DECIMAL(10,2)   NOT NULL,
    issue_type          VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_maintenance PRIMARY KEY (maintenance_id),
    CONSTRAINT fk_maint_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT chk_cost_non_negative CHECK (cost >= 0)
);
