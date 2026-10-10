-- ==============================================================================
-- 07_TIME_ANALYSIS.SQL: Time-Based Analytics (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- 1. Demand and Operations by Hour of Day
SELECT 
    booking_hour,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value,
    ROUND(AVG(customer_wait_time), 2) AS avg_vtat
FROM uber_features
GROUP BY booking_hour
ORDER BY booking_hour ASC;

-- 2. Demand by Day of the Week
SELECT 
    day_of_week,
    day_name,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS cancellation_rate_pct
FROM uber_features
GROUP BY day_of_week, day_name
ORDER BY day_of_week ASC;

-- 3. Monthly Demand & Revenue Trend
SELECT 
    month,
    month_name,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(SUM(CASE WHEN booking_status = 'Completed' THEN booking_value ELSE 0 END), 2) AS total_revenue,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value
FROM uber_features
GROUP BY month, month_name
ORDER BY month ASC;

-- 4. Weekday vs Weekend Comparison
SELECT 
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value,
    ROUND(AVG(customer_wait_time), 2) AS avg_vtat,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN driver_trip_time END), 2) AS avg_ctat
FROM uber_features
GROUP BY is_weekend;
