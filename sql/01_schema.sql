-- ==============================================================================
-- 01_SCHEMA.SQL: Table Definitions (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS uber_db;
USE uber_db;

DROP TABLE IF EXISTS uber_features;
DROP TABLE IF EXISTS uber_cleaned;
DROP TABLE IF EXISTS uber_kpi_summary;
DROP TABLE IF EXISTS raw_uber_data;

-- ------------------------------------------------------------------------------
-- Raw Staging Table
-- ------------------------------------------------------------------------------
CREATE TABLE raw_uber_data (
    booking_date                 VARCHAR(20),
    booking_time                 VARCHAR(20),
    booking_id                   VARCHAR(50),
    booking_status               VARCHAR(50),
    customer_id                  VARCHAR(50),
    vehicle_type                 VARCHAR(50),
    pickup_location              VARCHAR(100),
    drop_location                VARCHAR(100),
    avg_vtat                     DECIMAL(10, 2),
    avg_ctat                     DECIMAL(10, 2),
    customer_cancellation        INT,
    customer_cancellation_reason VARCHAR(255),
    driver_cancellation          INT,
    driver_cancellation_reason   VARCHAR(255),
    incomplete_rides             INT,
    incomplete_ride_reason       VARCHAR(255),
    booking_value                DECIMAL(10, 2),
    ride_distance                DECIMAL(10, 2),
    driver_rating                DECIMAL(3, 2),
    customer_rating              DECIMAL(3, 2),
    payment_method               VARCHAR(50)
);
