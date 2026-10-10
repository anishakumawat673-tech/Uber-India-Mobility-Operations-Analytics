# Uber India Mobility & Operations Analytics

A SQL-focused Data Analyst & Business Analyst portfolio project analyzing **Uber Data India 2024** (~148K records) using **MySQL** to evaluate booking demand, cancellation patterns, vehicle performance, turnaround times, and customer satisfaction.

---

## 🛠️ Technology Stack
* **Database**: MySQL 8.0+
* **Query Dialect**: Pure MySQL (`STR_TO_DATE`, `HOUR()`, `DAYOFWEEK()`, `DAYNAME()`, `MONTH()`, `CONCAT()`, `RANK()`, `DENSE_RANK()`, `CTEs`)
* **Python Libraries**: `pandas`, `matplotlib`, `pymysql`, `mysql-connector-python`, `sqlalchemy`, `reportlab`
* **Documentation**: Data Quality Report & Executive Business Summary

---

## 📊 Key KPIs & Operational Metrics

| Metric | Value | Meaning & Context |
| :--- | :--- | :--- |
| **Total Bookings** | 148,763 | Total ride requests across 2024 |
| **Completion Rate** | **60.55%** | Percentage of rides completed successfully |
| **Overall Cancellation Rate** | **32.54%** | Total ride cancellations (Customer + Driver) |
| **Customer Cancellation Rate** | 18.68% | Rides cancelled by riders (long wait times / driver delays) |
| **Driver Cancellation Rate** | 13.86% | Rides cancelled by drivers (traffic / distance / customer issues) |
| **Gross Booking Value (GBV)** | ₹ 41.08 Million | Total revenue generated from completed rides |
| **Average Booking Value (AOV)**| ₹ 456.09 | Average fare per completed ride |
| **Average Wait Time (VTAT)** | 7.00 min | Average Vehicle Turnaround Time (arrival time) |
| **Average Customer Rating** | 4.52 / 5.0 | Overall passenger satisfaction rating |

---

## 💡 Key Business Insights

1. **Peak Demand Concentration**: Rush hours (8–11 AM and 5–9 PM) drive over 57% of daily demand. During peak hours, average wait time (VTAT) increases by 40% (reaching ~9.8 minutes).
2. **Cancellation Root Causes**:
   * **Customer Cancellations**: 44% cite long wait times or driver not moving towards pickup.
   * **Driver Cancellations**: 52% cite heavy traffic or customer-related location issues. Higher in **Auto (16.2%)** and **Moto (15.8%)**.
3. **Vehicle Fleet Economics**: Premium categories (**UberXL** & **Premier**) yield the highest average fare (₹785 for XL) and maintain superior completion rates (>67%).
4. **Service Quality Threshold**: When driver wait time (VTAT) exceeds 8 minutes, customer satisfaction ratings drop significantly from 4.8★ to below 4.4★.

---

## 🚀 How to Set Up & Run with MySQL

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Set Up MySQL Database
Open your MySQL Client (MySQL CLI, MySQL Workbench, or DBeaver) and run:
```sql
CREATE DATABASE IF NOT EXISTS uber_db;
USE uber_db;
```

### 3. Load Raw Data into MySQL
You can load `data/raw/uber_data_india_2024.csv` into MySQL:
* **Option A: Using Python (`python/01_data_inspection.ipynb`)**:
  Run the notebook cells to automatically inspect and stage the dataset into `uber_db.raw_uber_data`.
* **Option B: Using MySQL `LOAD DATA INFILE` or Table Data Import Wizard**:
  Run `sql/01_schema.sql` first, then import `data/raw/uber_data_india_2024.csv`.

### 4. Execute SQL Analysis Scripts
Execute the SQL scripts in sequence:
```sql
SOURCE sql/01_schema.sql;
SOURCE sql/02_data_quality.sql;
SOURCE sql/03_etl.sql;
SOURCE sql/04_feature_engineering.sql;
SOURCE sql/05_kpis.sql;
SOURCE sql/06_vehicle_analysis.sql;
SOURCE sql/07_time_analysis.sql;
SOURCE sql/08_location_analysis.sql;
SOURCE sql/09_cancellation_analysis.sql;
SOURCE sql/10_business_analysis.sql;
```

### 5. View Visualizations
Open Jupyter notebook to view the charts:
```bash
jupyter notebook
```
Open `python/02_visualization.ipynb` to view the 7 clean, simple charts.

---

## 📝 Resume Bullets

* Engineered an end-to-end **MySQL ETL pipeline** to clean, standardize, and feature-engineer ~148K Uber India booking records into structured analytical tables (`uber_cleaned`, `uber_features`).
* Developed a comprehensive **SQL KPI & performance layer** using CTEs, aggregate CASE logic, and window functions (`RANK()`, `DENSE_RANK()`) to analyze completion rates (60.55%), cancellations (32.54%), and gross revenue (₹41.08M).
* Identified **operational bottlenecks**, such as wait time surges during rush hours and entry-segment cancellation spikes, presenting actionable recommendations and clean Python visualizations for business stakeholders.
