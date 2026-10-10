-- ==============================================================================
-- 09_CANCELLATION_ANALYSIS.SQL: Customer vs Driver Cancellation Analysis (MySQL Dialect)
-- Project: Uber Data India 2024 Analytics
-- ==============================================================================

USE uber_db;

-- 1. Customer Cancellation Reasons Breakdown
SELECT 
    customer_cancellation_reason,
    COUNT(*) AS total_cancellations,
    ROUND(100.0 * COUNT(*) / (SELECT SUM(customer_cancellation) FROM uber_features WHERE customer_cancellation = 1), 2) AS pct_share
FROM uber_features
WHERE customer_cancellation = 1 AND customer_cancellation_reason IS NOT NULL
GROUP BY customer_cancellation_reason
ORDER BY total_cancellations DESC;

-- 2. Driver Cancellation Reasons Breakdown
SELECT 
    driver_cancellation_reason,
    COUNT(*) AS total_cancellations,
    ROUND(100.0 * COUNT(*) / (SELECT SUM(driver_cancellation) FROM uber_features WHERE driver_cancellation = 1), 2) AS pct_share
FROM uber_features
WHERE driver_cancellation = 1 AND driver_cancellation_reason IS NOT NULL
GROUP BY driver_cancellation_reason
ORDER BY total_cancellations DESC;

-- 3. Cancellation Rate by Vehicle Type
SELECT 
    vehicle_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(customer_cancellation) / COUNT(*), 2) AS customer_cancel_rate_pct,
    ROUND(100.0 * SUM(driver_cancellation) / COUNT(*), 2) AS driver_cancel_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS total_cancel_rate_pct
FROM uber_features
GROUP BY vehicle_type
ORDER BY total_cancel_rate_pct DESC;

-- 4. Cancellation Rate by Demand Period (Peak vs Off-Peak)
SELECT 
    demand_period,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * SUM(customer_cancellation) / COUNT(*), 2) AS customer_cancel_rate_pct,
    ROUND(100.0 * SUM(driver_cancellation) / COUNT(*), 2) AS driver_cancel_rate_pct,
    ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS total_cancel_rate_pct,
    ROUND(AVG(customer_wait_time), 2) AS avg_vtat
FROM uber_features
GROUP BY demand_period;

-- 5. High-Risk Segments with Cancellation Rates Above Overall Average
WITH segment_cancellations AS (
    SELECT 
        vehicle_type,
        time_period,
        COUNT(*) AS total_rides,
        ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) AS segment_cancel_rate
    FROM uber_features
    GROUP BY vehicle_type, time_period
    HAVING COUNT(*) > 500
)
SELECT 
    vehicle_type,
    time_period,
    total_rides,
    segment_cancel_rate,
    (SELECT ROUND(100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*), 2) FROM uber_features) AS overall_avg_cancel_rate,
    ROUND(segment_cancel_rate - (SELECT 100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*) FROM uber_features), 2) AS excess_cancellation_pct
FROM segment_cancellations
WHERE segment_cancel_rate > (SELECT 100.0 * SUM(customer_cancellation + driver_cancellation) / COUNT(*) FROM uber_features)
ORDER BY segment_cancel_rate DESC;
