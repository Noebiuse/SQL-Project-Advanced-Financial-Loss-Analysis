-- SQL Project: Supply Chain Loss Analysis (Advanced Reporting)
-- Purpose: Demonstrate ability to use Window Functions for complex financial and operational reporting.
-- Context: Modeled data based on observed supply chain losses (PLN) linked to delays.
-- Target Audience: Financial and Operations Management.

-----------------------------------------------------------
-- 1. SETUP: Create Table and Insert Test Data
-----------------------------------------------------------

CREATE TABLE supply_chain_losses (
    order_date DATE,
    material_code VARCHAR(50),
    order_value_pln NUMERIC,
    delay_hours INTEGER,
    financial_loss_pln NUMERIC
);

-- Note: The following data is synthetic and used to demonstrate query logic.
INSERT INTO supply_chain_losses (order_date, material_code, order_value_pln, delay_hours, financial_loss_pln) VALUES
('2025-05-01', 'Steel', 50000, 5, 1000.00), 
('2025-05-02', 'Packaging', 15000, 2, 500.00),
('2025-05-03', 'Steel', 80000, 10, 2000.00), 
('2025-05-03', 'Plastic', 60000, 8, 1500.00), 
('2025-05-04', 'Packaging', 25000, 3, 750.00),
('2025-06-01', 'Chemicals', 40000, 6, 1200.00), 
('2025-06-02', 'Steel', 90000, 15, 3000.00); 

-----------------------------------------------------------
-- 2. QUERY 1: Running Total of Losses (Financial Trend Analysis)
-----------------------------------------------------------
-- Goal: Calculate the accumulated financial loss over time. 
-- Value: Helps identify when the total loss exceeds budget limits.
SELECT
    order_date,
    financial_loss_pln AS daily_loss,
    -- SUM() OVER performs a running calculation ordered by date.
    SUM(financial_loss_pln) OVER (ORDER BY order_date) AS cumulative_loss_pln
FROM
    supply_chain_losses
ORDER BY
    order_date;

-----------------------------------------------------------
-- 3. QUERY 2: Top Loss Days by Month (Anomaly Detection)
-----------------------------------------------------------
-- Goal: Rank days based on loss amount, resetting the rank for each new month.
-- Value: Directs operational teams to the worst-performing days for investigation.
SELECT 
    order_date,
    material_code,
    financial_loss_pln,
    -- PARTITION BY groups the data by month, then RANK() orders inside that group.
    RANK() OVER(
        PARTITION BY DATE_TRUNC('month', order_date)
        ORDER BY financial_loss_pln DESC
    ) AS daily_loss_rank
FROM
    supply_chain_losses
ORDER BY
    DATE_TRUNC('month', order_date), 
    daily_loss_rank;

-----------------------------------------------------------
-- 4. QUERY 3: Day-over-Day Change (Performance Monitoring)
-----------------------------------------------------------
-- Goal: Compare today's loss to yesterday's loss to spot sudden spikes or drops.
-- Value: Instant feedback on whether current measures are increasing or decreasing losses.
SELECT
    order_date,
    financial_loss_pln AS current_day_loss,
    -- LAG() pulls the loss value from the previous row (day). Defaulting to 0 if no prior day.
    LAG(financial_loss_pln, 1, 0) OVER (ORDER BY order_date) AS previous_day_loss,
    -- Calculate the difference (change). A negative result means less loss than yesterday.
    financial_loss_pln - LAG(financial_loss_pln, 1, 0) OVER (ORDER BY order_date) AS loss_change
FROM
    supply_chain_losses
ORDER BY
    order_date;