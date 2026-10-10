-- ==============================================================================
-- 06_VEHICLE_ANALYSIS.SQL: Vehicle Fleet Performance (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- 1. Vehicle Performance Matrix with Rankings
SELECT 
    vehicle_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) AS completed_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN ride_distance END), 2) AS avg_ride_distance,
    ROUND(AVG(customer_wait_time), 2) AS avg_vtat,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN driver_trip_time END), 2) AS avg_ctat,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    ROUND(AVG(driver_rating), 2) AS avg_driver_rating,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS volume_rank,
    DENSE_RANK() OVER (ORDER BY AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END) DESC) AS aov_rank
FROM uber_features
GROUP BY vehicle_type
ORDER BY total_bookings DESC;

-- 2. Vehicle Cancellation Rate vs Fleet Average Benchmark
WITH vehicle_rates AS (
    SELECT 
        vehicle_type,
        COUNT(*) AS total_bookings,
        ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS vehicle_cancel_rate
    FROM uber_features
    GROUP BY vehicle_type
)
SELECT 
    vehicle_type,
    total_bookings,
    vehicle_cancel_rate,
    (SELECT ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) FROM uber_features) AS overall_cancel_rate,
    ROUND(vehicle_cancel_rate - (SELECT 100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*) FROM uber_features), 2) AS difference_from_avg
FROM vehicle_rates
ORDER BY vehicle_cancel_rate DESC;