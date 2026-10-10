-- ==============================================================================
-- 08_LOCATION_ANALYSIS.SQL: Pickup, Drop & Route Analytics (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- 1. Top Pickup Locations Ranked by Booking Volume
SELECT 
    pickup_location,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS volume_rank
FROM uber_features
GROUP BY pickup_location
ORDER BY total_bookings DESC;

-- 2. Top Drop Locations Ranked by Booking Volume
SELECT 
    drop_location,
    COUNT(*) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS drop_volume_rank
FROM uber_features
GROUP BY drop_location
ORDER BY total_bookings DESC;

-- 3. Top Origin-Destination (OD) Routes Ranked by Volume
SELECT 
    route_od,
    COUNT(*) AS total_route_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN ride_distance END), 2) AS avg_distance_km,
    ROUND(AVG(customer_wait_time), 2) AS avg_vtat,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS route_rank
FROM uber_features
GROUP BY route_od
ORDER BY total_route_bookings DESC
LIMIT 10;
