-- ==============================================================================
-- 02_DATA_QUALITY.SQL: Pre-Cleaning Data Quality Checks (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- 1. Total Rows & Distinct Booking IDs
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT booking_id) AS distinct_booking_ids
FROM raw_uber_data;

-- 2. Check for Duplicate Booking IDs
SELECT 
    booking_id,
    COUNT(*) AS duplicate_count
FROM raw_uber_data
GROUP BY booking_id
HAVING COUNT(*) > 1;

-- 3. Check for Null Values Across Key Columns
SELECT 
    SUM(CASE WHEN booking_id IS NULL THEN 1 ELSE 0 END) AS null_booking_ids,
    SUM(CASE WHEN booking_date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN booking_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN vehicle_type IS NULL THEN 1 ELSE 0 END) AS null_vehicles,
    SUM(CASE WHEN booking_value IS NULL THEN 1 ELSE 0 END) AS null_values,
    SUM(CASE WHEN ride_distance IS NULL THEN 1 ELSE 0 END) AS null_distances,
    SUM(CASE WHEN avg_vtat IS NULL THEN 1 ELSE 0 END) AS null_vtat,
    SUM(CASE WHEN avg_ctat IS NULL THEN 1 ELSE 0 END) AS null_ctat
FROM raw_uber_data;

-- 4. Distinct Booking Statuses
SELECT 
    booking_status,
    COUNT(*) AS total_count
FROM raw_uber_data
GROUP BY booking_status
ORDER BY total_count DESC;

-- 5. Invalid Booking Values (<= 0 for Completed rides)
SELECT 
    COUNT(*) AS invalid_booking_values
FROM raw_uber_data
WHERE booking_status = 'Completed' AND (booking_value <= 0 OR booking_value IS NULL);

-- 6. Invalid Ride Distances (<= 0)
SELECT 
    COUNT(*) AS invalid_ride_distances
FROM raw_uber_data
WHERE ride_distance <= 0 OR ride_distance IS NULL;

-- 7. Invalid Ratings (Outside 1.0 to 5.0)
SELECT 
    COUNT(*) AS invalid_driver_ratings
FROM raw_uber_data
WHERE driver_rating IS NOT NULL AND (driver_rating < 1.0 OR driver_rating > 5.0);

SELECT 
    COUNT(*) AS invalid_customer_ratings
FROM raw_uber_data
WHERE customer_rating IS NOT NULL AND (customer_rating < 1.0 OR customer_rating > 5.0);

-- 8. Invalid Turnaround Times (Negative VTAT or CTAT)
SELECT 
    COUNT(*) AS invalid_vtat_count
FROM raw_uber_data
WHERE avg_vtat < 0;

SELECT 
    COUNT(*) AS invalid_ctat_count
FROM raw_uber_data
WHERE avg_ctat < 0;
