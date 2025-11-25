# SQL Project: Advanced Financial Loss Analysis

## Project Goal
This project demonstrates how to use **Advanced SQL Window Functions** to solve a critical business problem: analyzing and monitoring financial losses in the supply chain.

The analysis is based on **synthetic data** (loss amounts in PLN) that models a real-world scenario where operational delays lead to financial costs.

## Tools & Technologies
* **Database:** PostgreSQL (SQL script provided)
* **Key Skills:** Window Functions (`SUM() OVER`, `RANK() OVER`, `LAG() OVER`), Data Modeling, Financial Reporting.

***

## Key Analysis & Business Value

The script contains three main queries, each providing a different level of management insight:

### 1. Running Total of Losses (Trend Monitoring)
* **Query Used:** `SUM() OVER (ORDER BY date)`
* **Business Value:** This query calculates the **cumulative (accumulated) loss** over time. Management can quickly see when the total losses cross a critical budget threshold, allowing for immediate strategic intervention. It answers the question: *“How quickly is the total loss growing?”*

### 2. Top Loss Days per Month (Anomaly Detection)
* **Query Used:** `RANK() OVER (PARTITION BY month...)`
* **Business Value:** This query isolates and ranks the **worst-performing days** inside each calendar month. Using the `PARTITION BY` clause, we focus operational teams only on the few dates where extreme financial anomalies occurred, saving investigative time. It answers the question: *“What were the most critical loss days this month?”*

### 3. Day-over-Day Change (Performance Tracking)
* **Query Used:** `LAG() OVER (ORDER BY date)`
* **Business Value:** This query compares today's financial loss directly to the previous day's loss. This is crucial for **real-time performance monitoring**. A sharp positive change means the problem is escalating; a sharp negative change means a recent mitigation effort is working. It answers the question: *“Is the cost reduction strategy working as of today?”*

***

## How to Run the Script
The provided `financial_loss_analysis.sql` file contains the full setup:
1.  `CREATE TABLE` statement.
2.  `INSERT` statements with synthetic test data.
3.  All three analytical queries.

You can run the entire script in any PostgreSQL environment to recreate the tables and verify the analytical results.

---
