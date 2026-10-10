-- ==============================================================================
-- 05_KPIS.SQL: Core Fleet KPIs (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- 1. Demand & Fulfillment KPIs
SELECT 
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) AS completed_bookings,
    SUM(CASE WHEN incomplete_rides = 1 THEN 1 ELSE 0 END) AS incomplete_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct
FROM uber_features;

-- 2. Cancellation KPIs
SELECT 
    COUNT(*) AS total_bookings,
    SUM(customer_cancellation + driver_cancellation) AS total_cancellations,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS overall_cancellation_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation) / COUNT(*), 2) AS customer_cancellation_rate_pct,
    ROUND(100.0 * SUM(driver_cancellation) / COUNT(*), 2) AS driver_cancellation_rate_pct
FROM uber_features;

-- 3. Revenue & Pricing KPIs (Completed Rides)
SELECT 
    ROUND(SUM(booking_value), 2) AS total_booking_value,
    ROUND(AVG(booking_value), 2) AS avg_booking_value,
    ROUND(AVG(booking_value_per_km), 2) AS avg_booking_value_per_km
FROM uber_features
WHERE booking_status = 'Completed';

-- 4. Trip & Service Time KPIs
SELECT 
    ROUND(AVG(ride_distance), 2) AS avg_ride_distance_km,
    ROUND(AVG(customer_wait_time), 2) AS avg_vtat_wait_time,
    ROUND(AVG(driver_trip_time), 2) AS avg_ctat_trip_time
FROM uber_features
WHERE booking_status = 'Completed';

-- 5. Customer & Driver Experience KPIs
SELECT 
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    ROUND(AVG(driver_rating), 2) AS avg_driver_rating
FROM uber_features
WHERE customer_rating IS NOT NULL;

-- 6. Store KPI Summary in a Table
DROP TABLE IF EXISTS uber_kpi_summary;

CREATE TABLE uber_kpi_summary AS
SELECT 
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation) / COUNT(*), 2) AS customer_cancellation_rate_pct,
    ROUND(100.0 * SUM(driver_cancellation) / COUNT(*), 2) AS driver_cancellation_rate_pct,
    ROUND(SUM(CASE WHEN booking_status = 'Completed' THEN booking_value ELSE 0 END), 2) AS total_revenue_inr,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_booking_value_inr,
    ROUND(AVG(customer_wait_time), 2) AS avg_wait_time_vtat,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM uber_features;

SELECT * FROM uber_kpi_summary;
