-- ==============================================================================
-- 04_FEATURE_ENGINEERING.SQL: SQL Feature Engineering (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- Target Table: uber_features
-- ==============================================================================

USE uber_db;

DROP TABLE IF EXISTS uber_features;

CREATE TABLE uber_features AS
SELECT 
    booking_id,
    customer_id,
    booking_date,
    booking_time,
    booking_hour,
    
    -- 1. Day of Week & Month (MySQL functions)
    DAYOFWEEK(booking_date) AS day_of_week,
    DAYNAME(booking_date) AS day_name,
    MONTH(booking_date) AS month,
    MONTHNAME(booking_date) AS month_name,
    CASE 
        WHEN DAYOFWEEK(booking_date) IN (1, 7) THEN 1 
        ELSE 0 
    END AS is_weekend,
    
    -- 2. Time Period (Morning, Afternoon, Evening, Night)
    CASE 
        WHEN booking_hour BETWEEN 6 AND 11 THEN 'Morning'
        WHEN booking_hour BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN booking_hour BETWEEN 17 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_period,
    
    -- 3. Demand Period (Peak: 8-11 AM & 5-9 PM on weekdays)
    CASE 
        WHEN DAYOFWEEK(booking_date) NOT IN (1, 7) 
         AND (booking_hour BETWEEN 8 AND 11 OR booking_hour BETWEEN 17 AND 21) 
        THEN 'Peak'
        ELSE 'Off-Peak'
    END AS demand_period,
    
    -- 4. Distance Category
    ride_distance,
    CASE 
        WHEN ride_distance < 5.0 THEN 'Short'
        WHEN ride_distance BETWEEN 5.0 AND 15.0 THEN 'Medium'
        ELSE 'Long'
    END AS distance_category,
    
    -- 5. Trip Economics (Booking value per km for completed rides)
    booking_value,
    CASE 
        WHEN ride_distance > 0 AND booking_status = 'Completed' 
        THEN ROUND(booking_value / ride_distance, 2)
        ELSE NULL 
    END AS booking_value_per_km,
    
    -- 6. Service Metrics
    avg_vtat AS customer_wait_time,
    avg_ctat AS driver_trip_time,
    
    -- Core dimensions
    vehicle_type,
    pickup_location,
    drop_location,
    CONCAT(pickup_location, ' -> ', drop_location) AS route_od,
    booking_status,
    customer_cancellation,
    customer_cancellation_reason,
    driver_cancellation,
    driver_cancellation_reason,
    incomplete_rides,
    incomplete_ride_reason,
    driver_rating,
    customer_rating,
    payment_method

FROM uber_cleaned;

-- Quick feature verification
SELECT 
    time_period,
    demand_period,
    distance_category,
    COUNT(*) AS total_rides,
    ROUND(AVG(booking_value), 2) AS avg_fare
FROM uber_features
GROUP BY time_period, demand_period, distance_category
ORDER BY total_rides DESC
LIMIT 5;
