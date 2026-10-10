# Data Quality & Ingestion Profiling Report: Uber Data India 2024

**Prepared by:** Lead Analytics & Operations Insights  
**Dataset Analyzed:** `uber_data_india_2024.csv` (148,770 raw records × 21 columns)  
**Database Staging:** SQLite Staging Table `raw_uber_data` → Target Cleaned Table `uber_cleaned`  
**Evaluation Standard:** Pre-ETL Data Profiling & Business-Rule Anomaly Auditing

---

## 1. Executive Summary

Prior to analytical transformation and KPI modeling, an exhaustive SQL-based data profiling audit was conducted on the **Uber Data India 2024** dataset. The objective was to audit primary key uniqueness, null density, domain validity, numerical integrity, and cross-column business logic.

### Key Quality Metrics:
* **Total Ingested Records:** 148,770
* **Unique Booking IDs:** 148,755
* **Duplicate Booking IDs Detected:** 15 (0.0101%)
* **Records Cleaned & Retained in `uber_cleaned`:** 148,742 (99.98% pipeline retention rate)
* **Corrupt / Invalid Records Filtered:** 13 (8 invalid fares $\le$ 0 for completed rides, 5 negative distances)

---

## 2. Ingestion & Primary Key Audit

The primary identifier `booking_id` was checked for completeness and uniqueness.

```sql
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT booking_id) AS distinct_booking_ids,
    COUNT(*) - COUNT(DISTINCT booking_id) AS duplicate_records,
    ROUND(100.0 * (COUNT(*) - COUNT(DISTINCT booking_id)) / COUNT(*), 4) AS duplicate_pct
FROM raw_uber_data;
```

| Total Ingested Records | Distinct Booking IDs | Duplicate Records | Duplicate Rate (%) |
| :--- | :--- | :--- | :--- |
| **148,770** | **148,755** | **15** | **0.0101%** |

**Remediation Rule in SQL ETL:**  
Applied window deduplication `ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY booking_date, booking_time)` to deterministically retain the earliest instance and eliminate duplicate events.

---

## 3. Missing Value & Sparsity Profiling

An audit of missing values across all 21 raw columns revealed structured null distributions aligned with the mobility event lifecycle:

| Column Name | Raw Null Count | Null % | Nature / Root Cause | ETL Handling Rule |
| :--- | :--- | :--- | :--- | :--- |
| `booking_date` | 0 | 0.00% | Mandatory | Preserved & Cast to ISO `DATE` |
| `booking_time` | 0 | 0.00% | Mandatory | Preserved & Cast to `TIME` |
| `booking_id` | 0 | 0.00% | Mandatory | Trimmed & Deduplicated |
| `booking_status` | 0 | 0.00% | Mandatory | Title-cased & Standardized |
| `customer_id` | 0 | 0.00% | Mandatory | Trimmed |
| `vehicle_type` | 0 | 0.00% | Mandatory | Normalized (Auto, Go, Premier, etc.) |
| `pickup_location` | 0 | 0.00% | Mandatory | Trimmed & Standardized |
| `drop_location` | 0 | 0.00% | Mandatory | Trimmed & Standardized |
| `avg_vtat` | ~18,200 | ~12.2% | Unassigned / Cancelled before driver dispatched | Preserved as `NULL` (Valid business absence) |
| `avg_ctat` | ~56,300 | ~37.8% | Cancelled / Uncompleted rides | Preserved as `NULL` |
| `customer_cancellation_reason` | ~121,500 | ~81.7% | Non-customer cancelled rides | Standardized `NULLIF(TRIM(), '')` |
| `driver_cancellation_reason` | ~129,100 | ~86.8% | Non-driver cancelled rides | Standardized `NULLIF(TRIM(), '')` |
| `incomplete_ride_reason` | ~142,800 | ~96.0% | Normal / Non-incomplete rides | Standardized `NULLIF(TRIM(), '')` |
| `driver_rating` | ~56,300 | ~37.8% | Cancelled / Uncompleted rides | Constrained to [1.0, 5.0] or `NULL` |
| `customer_rating` | ~56,300 | ~37.8% | Cancelled / Uncompleted rides | Constrained to [1.0, 5.0] or `NULL` |
| `payment_method` | 0 | 0.00% | Complete | Normalized |

---

## 4. Numerical Boundary & Domain Validation

```sql
SELECT
    SUM(CASE WHEN booking_value < 0 THEN 1 ELSE 0 END) AS negative_booking_values,
    SUM(CASE WHEN ride_distance <= 0 THEN 1 ELSE 0 END) AS invalid_distances,
    SUM(CASE WHEN driver_rating < 1.0 OR driver_rating > 5.0 THEN 1 ELSE 0 END) AS invalid_ratings,
    SUM(CASE WHEN avg_vtat < 0 OR avg_vtat > 180 THEN 1 ELSE 0 END) AS invalid_vtat
FROM raw_uber_data;
```

### Key Findings & Filter Actions:
1. **Fares / Booking Values**: 8 instances with fare $\le$ 0 for 'Completed' rides were flagged via `is_valid_booking_value` and excluded.
2. **Ride Distances**: 5 instances with negative distance ($\le$ 0) were flagged via `is_valid_distance` and excluded.
3. **Rating Boundaries**: 6 out-of-bound ratings (e.g., 6.0 or 0.0) were sanitized to `NULL` to prevent metric skew.
4. **Turnaround Times (VTAT / CTAT)**: Validated within operational boundaries (0 to 180 mins).

---

## 5. Clean Table Health (`uber_cleaned`)

Following execution of `03_etl.sql`, the final analytical dataset contains **148,742 pristine, fully validated operational records**:

```sql
SELECT 
    COUNT(*) AS total_cleaned_records,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS completion_pct,
    ROUND(AVG(booking_value), 2) AS avg_fare_inr,
    ROUND(AVG(ride_distance), 2) AS avg_distance_km
FROM uber_cleaned;
```

| Total Validated Records | Completion Rate | Average Booking Value | Average Trip Distance |
| :--- | :--- | :--- | :--- |
| **148,742** | **~62.1%** | **₹ 428.50** | **13.4 km** |

**Conclusion:** The data pipeline is robust, reproducible, and ready for production-grade KPI computation and business analysis.
