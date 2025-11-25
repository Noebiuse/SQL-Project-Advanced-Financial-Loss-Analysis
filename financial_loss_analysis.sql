-- SQL Project: Supply Chain Loss Analysis (Advanced Reporting)
-- Purpose: Demonstrate ability to use Window Functions for complex financial and operational reporting.
-- Context: Modeled data based on observed supply chain losses (PLN) linked to delivery delays.
-- Target Audience: Financial and Operations Management.

-- NOTE ON DATA ARCHITECTURE: 
-- In a real-world production environment with large datasets, 
-- this CTE logic would be replaced by a scheduled ETL process 
-- that creates a permanent, indexed 'cleaned_data' table 
-- for optimal query performance and consistency across analytical tools.

-----------------------------------------------------------
-- 1. SETUP: Create Table and Insert Synthetic Data
-----------------------------------------------------------

CREATE TABLE supply_chain_losses (
    order_date DATE,
    material_code VARCHAR(50),
    order_value_pln NUMERIC,
    delay_hours INTEGER,
    financial_loss_pln NUMERIC
);

INSERT INTO supply_chain_losses (order_date, material_code, order_value_pln, delay_hours, financial_loss_pln) VALUES
('2025-05-01', 'Steel', 50000, 5, 1000.00), 
('2025-05-02', 'Packaging', 15000, 2, 500.00),
('2025-05-03', 'Steel', 80000, 10, 2000.00), 
('2025-05-03', 'Plastic', 60000, 8, 1500.00), 
('2025-05-04', 'Packaging', 25000, 3, 750.00),
('2025-06-01', 'Chemicals', 40000, 6, 1200.00), 
('2025-06-02', 'Steel', 90000, 15, 3000.00),
('2025-06-03', 'Electronics', 0, 1, NULL); 

-----------------------------------------------------------
-- 2. DATA CLEANSING & ROBUSTNESS (CTE)
-----------------------------------------------------------

-- CTE for data preparation: handles NULLs and implements basic business logic.

WITH clean_loss_data AS (
    SELECT
        order_date,
        material_code,
        -- Replaces NULL financial losses with 0 for accurate aggregation.
        COALESCE(financial_loss_pln, 0) AS safe_financial_loss,
        delay_hours,
        order_value_pln,
        -- Categorization for simple operational segmentation.
        CASE
            WHEN delay_hours >= 10 THEN 'High Delay'
            ELSE 'Normal Delay'
        END AS delay_category
    FROM
        supply_chain_losses
)

-----------------------------------------------------------
-- 3. QUERY 1: Running Total of Losses (Financial Trend Analysis)
-----------------------------------------------------------
-- Goal: Calculate the accumulated financial loss over time.
-- Value: Helps identify when the total loss exceeds budget limits.

SELECT
    order_date,
    safe_financial_loss AS daily_loss,
    SUM(safe_financial_loss) OVER (ORDER BY order_date) AS cumulative_loss_pln
FROM
    clean_loss_data
ORDER BY
    order_date;

-----------------------------------------------------------
-- 4. QUERY 2: Top Loss Days by Month (Anomaly Detection)
-----------------------------------------------------------
-- Goal: Rank days based on loss amount, resetting the rank for each new month.
-- Value: Directs operational teams to the worst-performing days for investigation.

SELECT 
    order_date,
    material_code,
    safe_financial_loss,
    -- PARTITION BY groups the data by month, then RANK() orders inside that group.
    RANK() OVER(
        PARTITION BY DATE_TRUNC('month', order_date)
        ORDER BY safe_financial_loss DESC
    ) AS daily_loss_rank
FROM
    clean_loss_data
ORDER BY
    DATE_TRUNC('month', order_date), 
    daily_loss_rank;

-----------------------------------------------------------
-- 5. QUERY 3: Day-over-Day Change (Performance Monitoring)
-----------------------------------------------------------
-- Goal: Compare today's loss to yesterday's loss to spot sudden spikes or drops.
-- Value: Instant feedback on whether current measures are increasing or decreasing losses.

SELECT
    order_date,
    safe_financial_loss AS current_day_loss,
    -- LAG() pulls the loss value from the previous row (day). Defaulting to 0 if no prior day.
    LAG(safe_financial_loss, 1, 0) OVER (ORDER BY order_date) AS previous_day_loss,
    -- Calculate the difference (change). A negative result means less loss than yesterday.
    safe_financial_loss - LAG(safe_financial_loss, 1, 0) OVER (ORDER BY order_date) AS loss_change
FROM
    clean_loss_data
ORDER BY
    order_date;

-----------------------------------------------------------
-- 6. QUERY 4: Material Loss Efficiency Rank (KPI Calculation)
-----------------------------------------------------------
-- Goal: Calculate the average financial loss per hour of delay for each material code.
-- Value: Ranks materials by operational inefficiency, directing resource allocation decisions.

WITH material_summary AS (
    SELECT
        material_code,
        -- Calculate the average loss per hour. NULLIF protects against division by zero 
        -- (in case total delay_hours is 0 for a material).
        SUM(safe_financial_loss) * 1.0 / NULLIF(SUM(delay_hours), 0) AS loss_per_hour_pln
    FROM
        clean_loss_data
    GROUP BY
        material_code
)

SELECT
    material_code,
    -- Formatting the result for readability (e.g., to 2 decimal places)
    ROUND(loss_per_hour_pln, 2) AS avg_loss_per_delay_hour,
    -- Rank materials based on the calculated KPI (higher loss_per_hour_pln is worse).
    RANK() OVER (ORDER BY loss_per_hour_pln DESC) AS inefficiency_rank
FROM
    material_summary
WHERE
    loss_per_hour_pln IS NOT NULL -- Exclude materials with no loss or delay data
ORDER BY
    inefficiency_rank;
