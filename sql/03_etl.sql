-- ==============================================================================
-- 03_ETL.SQL: Data Cleaning & Transformation (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- Target Table: uber_cleaned
-- ==============================================================================

USE uber_db;

DROP TABLE IF EXISTS uber_cleaned;

-- Create cleaned analytical table
CREATE TABLE uber_cleaned AS
SELECT
    -- Identifiers
    TRIM(booking_id) AS booking_id,
    TRIM(customer_id) AS customer_id,
    
    -- Date & Time fields
    CAST(TRIM(booking_date) AS DATE) AS booking_date,
    CAST(TRIM(booking_time) AS TIME) AS booking_time,
    HOUR(TRIM(booking_time)) AS booking_hour,
    
    -- Standardized categories
    TRIM(booking_status) AS booking_status,
    TRIM(vehicle_type) AS vehicle_type,
    TRIM(pickup_location) AS pickup_location,
    TRIM(drop_location) AS drop_location,
    
    -- Service turnaround times (preserve valid NULLs)
    CASE 
        WHEN avg_vtat BETWEEN 0 AND 180 THEN ROUND(avg_vtat, 2) 
        ELSE NULL 
    END AS avg_vtat,
    
    CASE 
        WHEN avg_ctat BETWEEN 0 AND 360 THEN ROUND(avg_ctat, 2) 
        ELSE NULL 
    END AS avg_ctat,
    
    -- Cancellation details
    COALESCE(customer_cancellation, 0) AS customer_cancellation,
    NULLIF(TRIM(customer_cancellation_reason), '') AS customer_cancellation_reason,
    COALESCE(driver_cancellation, 0) AS driver_cancellation,
    NULLIF(TRIM(driver_cancellation_reason), '') AS driver_cancellation_reason,
    COALESCE(incomplete_rides, 0) AS incomplete_rides,
    NULLIF(TRIM(incomplete_ride_reason), '') AS incomplete_ride_reason,
    
    -- Numeric fields
    ROUND(booking_value, 2) AS booking_value,
    ROUND(ride_distance, 2) AS ride_distance,
    
    -- Ratings (1.0 to 5.0 only)
    CASE 
        WHEN driver_rating BETWEEN 1.0 AND 5.0 THEN driver_rating 
        ELSE NULL 
    END AS driver_rating,
    
    CASE 
        WHEN customer_rating BETWEEN 1.0 AND 5.0 THEN customer_rating 
        ELSE NULL 
    END AS customer_rating,
    
    TRIM(payment_method) AS payment_method

FROM raw_uber_data
-- Filter out invalid distances and invalid completed fares
WHERE (ride_distance > 0)
  AND (booking_status != 'Completed' OR booking_value > 0);

-- Verify row count in cleaned table
SELECT COUNT(*) AS total_cleaned_rows FROM uber_cleaned;
