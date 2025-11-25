# SQL Project: Supply Chain Loss Analysis

This project demonstrates how I used SQL to analyze financial losses caused by delivery delays in a supply-chain process. The dataset includes synthetic daily records with materials, order values, delay hours, and financial losses.

## Tools and Skills
* PostgreSQL
* SQL Window Functions: SUM() OVER, RANK() OVER, LAG()
* Data cleaning with COALESCE
* Basic KPI calculation

---

## Project Overview

### 1. Data Cleaning (CTE)
I used a CTE to handle data preparation. **I chose this method over creating a new permanent table to keep the entire project logic from cleaning to analysis contained within a single, easy-to-read script.** The CTE was used to:
* replace missing financial loss values with 0,
* keep the dataset consistent for analysis,
* add a simple delay category.

### 2. Running Total of Losses
Using SUM() OVER (ORDER BY order_date) I calculated the cumulative financial loss over time to see how losses grow day by day.

### 3. Top Loss Days per Month
With RANK() and PARTITION BY month, I identified the highest-loss days within each month to highlight anomalies and critical dates.

### 4. Day-over-Day Loss Change
Using LAG(), I compared each day’s loss to the previous day to detect sudden spikes or improvements in operational performance.

### 5. KPI: Loss per Delay Hour
I calculated a simple KPI — total financial loss divided by total delay hours for each material — and ranked materials by inefficiency.

## Result
The project shows my ability to:
* prepare and clean data,
* work with SQL window functions,
* build simple KPIs,
* extract insights from operational datasets.

The full SQL script used in this project is included in the repository.
