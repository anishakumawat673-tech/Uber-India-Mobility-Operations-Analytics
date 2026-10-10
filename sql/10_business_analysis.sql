-- ==============================================================================
-- 10_BUSINESS_ANALYSIS.SQL: 15 Core Business Questions (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- Q1: What is the overall booking completion rate?
SELECT 
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) AS completed_bookings,
    ROUND(100.0 * AVG(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END), 2) AS completion_rate_pct
FROM uber_features;

-- Q2: What is the overall cancellation rate and customer vs driver split?
SELECT 
    COUNT(*) AS total_bookings,
    ROUND(100.0 * AVG(customer_cancellation + driver_cancellation), 2) AS overall_cancellation_rate_pct,
    ROUND(100.0 * AVG(customer_cancellation), 2) AS customer_cancellation_rate_pct,
    ROUND(100.0 * AVG(driver_cancellation), 2) AS driver_cancellation_rate_pct
FROM uber_features;

-- Q3: Which vehicle types have the highest booking volume?
SELECT 
    vehicle_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM uber_features), 2) AS volume_share_pct
FROM uber_features
GROUP BY vehicle_type
ORDER BY total_bookings DESC;

-- Q4: Which vehicle types have higher/lower cancellation rates?
SELECT 
    vehicle_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * AVG(customer_cancellation + driver_cancellation), 2) AS cancellation_rate_pct
FROM uber_features
GROUP BY vehicle_type
ORDER BY cancellation_rate_pct DESC;

-- Q5: What are the top 5 peak booking hours?
SELECT 
    booking_hour,
    COUNT(*) AS total_bookings
FROM uber_features
GROUP BY booking_hour
ORDER BY total_bookings DESC
LIMIT 5;

-- Q6: Which days of the week have the highest demand?
SELECT 
    day_name,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM uber_features), 2) AS share_pct
FROM uber_features
GROUP BY day_name, day_of_week
ORDER BY day_of_week ASC;

-- Q7: Are weekend and weekday patterns different?
SELECT 
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * AVG(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END), 2) AS completion_rate_pct,
    ROUND(100.0 * AVG(customer_cancellation + driver_cancellation), 2) AS cancellation_rate_pct,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_fare,
    ROUND(AVG(customer_wait_time), 2) AS avg_wait_time_min
FROM uber_features
GROUP BY is_weekend;

-- Q8: Which pickup locations generate the most bookings and revenue?
SELECT 
    pickup_location,
    COUNT(*) AS total_bookings,
    ROUND(SUM(CASE WHEN booking_status = 'Completed' THEN booking_value ELSE 0 END), 2) AS total_revenue
FROM uber_features
GROUP BY pickup_location
ORDER BY total_bookings DESC
LIMIT 10;

-- Q9: Which routes (Origin -> Destination) have the highest booking volume?
SELECT 
    route_od,
    COUNT(*) AS total_bookings,
    ROUND(AVG(CASE WHEN booking_status = 'Completed' THEN booking_value END), 2) AS avg_fare
FROM uber_features
GROUP BY route_od
ORDER BY total_bookings DESC
LIMIT 10;

-- Q10: Which vehicle types have higher average fares?
SELECT 
    vehicle_type,
    ROUND(AVG(booking_value), 2) AS avg_fare,
    ROUND(AVG(booking_value_per_km), 2) AS avg_fare_per_km
FROM uber_features
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY avg_fare DESC;

-- Q11: Which operational segments have high cancellation rates?
SELECT 
    vehicle_type,
    time_period,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * AVG(customer_cancellation + driver_cancellation), 2) AS cancellation_rate_pct
FROM uber_features
GROUP BY vehicle_type, time_period
HAVING COUNT(*) > 500
ORDER BY cancellation_rate_pct DESC
LIMIT 5;

-- Q12: How does customer waiting time (VTAT) vary by vehicle type?
SELECT 
    vehicle_type,
    ROUND(AVG(customer_wait_time), 2) AS avg_wait_time_min
FROM uber_features
GROUP BY vehicle_type
ORDER BY avg_wait_time_min ASC;

-- Q13: How does customer rating vary by vehicle type?
SELECT 
    vehicle_type,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    ROUND(AVG(driver_rating), 2) AS avg_driver_rating
FROM uber_features
WHERE customer_rating IS NOT NULL
GROUP BY vehicle_type
ORDER BY avg_customer_rating DESC;

-- Q14: How does performance differ during Peak vs Off-Peak periods?
SELECT 
    demand_period,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * AVG(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END), 2) AS completion_rate_pct,
    ROUND(100.0 * AVG(customer_cancellation + driver_cancellation), 2) AS cancellation_rate_pct,
    ROUND(AVG(customer_wait_time), 2) AS avg_wait_time_min
FROM uber_features
GROUP BY demand_period;

-- Q15: What are the top customer cancellation reasons?
SELECT 
    customer_cancellation_reason,
    COUNT(*) AS cancellation_count
FROM uber_features
WHERE customer_cancellation = 1 AND customer_cancellation_reason IS NOT NULL
GROUP BY customer_cancellation_reason
ORDER BY cancellation_count DESC;
