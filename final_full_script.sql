    -- AMAZON SALES ANALYSIS PROJECT --
--  Purpose : End-to-end SQL project for Amazon sales dataset 
-- ============================================================ 
-- 1. DATABASE SETUP
-- ============================================================ 
CREATE DATABASE IF NOT EXISTS amazon_sales;
USE amazon_sales;
-- ============================================================
-- 2. TABLE SCHEMA DEFINITION
-- ============================================================
DROP TABLE IF EXISTS sales_data;
CREATE TABLE sales_data (
    order_id          VARCHAR(255) PRIMARY KEY,
    order_date        DATE,
    product_name      VARCHAR(255),
    category          VARCHAR(255),
    price             DECIMAL(10, 2),
    quantity          INT,
    total_sales       DECIMAL(10, 2),
    customer_name     VARCHAR(255),
    customer_location VARCHAR(255),
    payment_method    VARCHAR(255),
    order_status      VARCHAR(255)
);
-- ============================================================
-- 3. DATA LOADING
-- ============================================================
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\amazon_sales_data 2025.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- Quick sanity check
-- ============================================================
SELECT * FROM sales_data
LIMIT 10;

-- ============================================================
-- 4. DATA QUALITY CHECKS
-- ============================================================
-- 4.1 Check for duplicate order IDs
SELECT 
order_id, 
COUNT(*) AS duplicate_count
FROM sales_data
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 4.2 Check for missing customer locations
SELECT 
COUNT(*) AS missing_location_rows
FROM sales_data
WHERE customer_location IS NULL;

-- ============================================================
-- 5. DATA CLEANING
-- ============================================================
-- 5.1 Replace NULL customer_location with 'Unknown'
UPDATE sales_data
SET customer_location = 'Unknown'
WHERE customer_location IS NULL;

-- ============================================================
-- 6. EXPLORATORY SALES ANALYSIS (AGGREGATIONS)
-- ============================================================

-- 6.1 Total sales by product category
SELECT 
category, 
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY category 
ORDER BY total_sales DESC;

-- 6.2 Total sales by payment method
SELECT 
payment_method, 
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY payment_method 
ORDER BY total_sales DESC;

-- 6.3 Monthly / yearly sales trends
SELECT
EXTRACT(YEAR  FROM order_date)  AS year,
EXTRACT(MONTH FROM order_date)  AS month,
SUM(total_sales)                AS total_sales
FROM sales_data
GROUP BY year, month 
ORDER BY year DESC, month DESC;

-- 6.4 Total sales by customer (top customers)
SELECT 
customer_name, 
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY customer_name
ORDER BY total_sales DESC;

-- 6.5 Total sales by order status
SELECT 
order_status, 
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY order_status
ORDER BY total_sales DESC;

-- 6.6 Sales by payment method over time (year + month)
SELECT 
EXTRACT(YEAR  FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
payment_method,
SUM(total_sales)               AS total_sales
FROM sales_data
GROUP BY year, month, payment_method
ORDER BY year DESC, month DESC, total_sales DESC;

-- 6.7 Total sales by customer location (cities)
SELECT 
customer_location, 
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY customer_location
ORDER BY total_sales DESC;

-- 6.8 Total sales by product
SELECT 
product_name, 
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY product_name
ORDER BY total_sales DESC;

-- ============================================================
-- 7. ADVANCED SQL ANALYSIS
-- ============================================================

-- ============================================================
-- 7.1 MONTHLY CUMULATIVE SALES & MOVING AVERAGE (WINDOW FUNCTIONS)
--    Goal: Show monthly revenue, running total, and 3-month moving average
-- ============================================================
-- 7.1.A Monthly sales (base query for all time-series analysis)
SELECT
DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
SUM(total_sales) AS monthly_sales
FROM sales_data
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY month_start;

-- 7.1.B Monthly sales with cumulative (running) total
SELECT
ms.month_start,
ms.monthly_sales,
SUM(ms.monthly_sales) OVER (
ORDER BY ms.month_start
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS cumulative_sales
FROM (
SELECT 
DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
SUM(total_sales) AS monthly_sales
FROM sales_data
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
) AS ms
ORDER BY ms.month_start;

-- 7.1.C — 3-Month Moving Average (Rolling Average)
SELECT 
ms.month_start,
ms.monthly_sales,
-- 1) Cumulative running total
SUM(ms.monthly_sales) OVER (
ORDER BY ms.month_start
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
) AS cumulative_sales, 
-- 2) 3-month moving average
AVG(ms.monthly_sales) OVER (
ORDER BY ms.month_start
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3m
FROM (
SELECT 
DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
 SUM(total_sales) AS monthly_sales
FROM sales_data
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
) AS ms
ORDER BY ms.month_start;

-- ============================================================
-- 7.2 RANKING ANALYSIS (WINDOW FUNCTIONS)
-- ============================================================

-- 7.2.1 Rank products by total sales (overall)
SELECT 
p.product_name, 
p.total_sales,
RANK() OVER (
ORDER BY p.total_sales DESC
) AS sales_rank
FROM (
SELECT 
product_name,
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY product_name 
) AS p
ORDER BY sales_rank;

-- 7.2.2 Rank products within each category
SELECT 
c.category,
c.product_name,
c.total_sales,
RANK() OVER (
PARTITION BY c.category 
ORDER BY c.total_sales DESC
) AS category_rank
FROM (
SELECT 
category,
product_name,
SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY category, product_name
) AS c
ORDER BY c.category, category_rank;

-- 7.2.3 Rank customers by total spend
SELECT 
c.customer_name, 
c.total_spent,
RANK() OVER (
ORDER BY c.total_spent DESC
) AS customer_rank
FROM (
SELECT 
customer_name,
SUM(total_sales) AS total_spent
FROM sales_data
GROUP BY customer_name 
) AS c
ORDER BY customer_rank;

-- 7.3 CUSTOMER SEGMENTATION
-- ============================================================

-- 7.3.1 Customer summary: spend, frequency, avg order value
SELECT
c.customer_name,
c.total_orders,
c.total_spent,
c.avg_order_value,
c.first_order_date,
c.last_order_date
FROM (
SELECT 
customer_name,
COUNT(DISTINCT order_id) AS total_orders,
SUM(total_sales) AS total_spent,
AVG(total_Sales) AS avg_order_value,
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date
FROM sales_data
GROUP BY customer_name
) AS c
ORDER BY total_spent DESC;

-- 7.3.2 Spend-based segmentation (High, Medium, Low value customers)
SELECT
c.customer_name,
c.total_orders,
c.total_spent,
CASE
WHEN c.total_spent >= 30000 THEN 'High-Value Customer'
WHEN c.total_spent BETWEEN 15000 AND 29999 THEN 'Medium-Value Customer'
ELSE 'Low-Value Customer'
END AS customer_segment
FROM (
SELECT
customer_name,
COUNT(DISTINCT order_id) AS total_orders,
SUM(total_sales) AS total_spent
FROM sales_data
GROUP BY customer_name
) AS c
ORDER BY c.total_spent DESC;

-- ============================================================
-- 7.4 MONTH-OVER-MONTH (MoM) GROWTH ANALYSIS
-- ============================================================

-- 7.4.1 Monthly sales with previous month's sales (LAG)
WITH monthly_sales AS (
SELECT
DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
SUM(total_sales) AS monthly_sales
FROM sales_data
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
),
monthly_with_prev AS (
SELECT
month_start,
monthly_sales, 
LAG(monthly_sales) OVER (
ORDER BY month_start
) AS prev_month_sales
FROM monthly_sales
)
SELECT
month_start,
monthly_sales,
prev_month_sales,
ROUND(
CASE 
WHEN prev_month_sales IS NULL OR prev_month_sales = 0 THEN NULL
ELSE ((monthly_sales - prev_month_sales) / prev_month_sales) * 100
END,
2
) AS mom_growth_pct
FROM monthly_with_prev
ORDER BY month_start;

-- ============================================================
-- 7.5 YEAR-OVER-YEAR (YoY) GROWTH ANALYSIS
-- ============================================================

-- 7.5.1 Yearly sales with previous year's sales (LAG)
WITH yearly_sales AS (
SELECT
EXTRACT(YEAR FROM order_date) AS year,
SUM(total_sales) AS yearly_sales
FROM sales_data
GROUP BY EXTRACT(YEAR FROM order_date)
),
yearly_with_prev AS (
SELECT
year,
yearly_sales, 
LAG(yearly_sales) OVER (
ORDER BY year
) AS prev_year_sales
FROM yearly_sales
)
SELECT
year,
yearly_sales,
prev_year_sales,
ROUND(
CASE 
WHEN prev_year_sales IS NULL OR prev_year_sales = 0 THEN NULL
ELSE ((yearly_sales - prev_year_sales) / prev_year_sales) * 100
END,
2
) AS yoy_growth_pct
FROM yearly_with_prev
ORDER BY year;

-- ============================================================
-- 7.6 CATEGORY-LEVEL MOVING AVERAGES & CUMULATIVE TOTALS
-- ============================================================

-- 7.6.1 Monthly category sales with cumulative & 3-month moving avg
WITH category_monthly AS (
SELECT
category,
DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
SUM(total_sales) AS category_monthly_sales
FROM sales_data
GROUP BY category, DATE_FORMAT(order_date, '%Y-%m-01')
)
SELECT
category,
month_start,
category_monthly_sales,

-- Cumulative sales per category
SUM(category_monthly_sales) OVER (
PARTITION BY category
ORDER BY month_start
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS cumulative_sales_category,

-- 3-month moving average per category
AVG(category_monthly_sales) OVER (
PARTITION BY category
ORDER BY month_start
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_avg_3m_category

FROM category_monthly
ORDER BY category, month_start;

-- ============================================================
-- 7.7 NEW VS RETURNING CUSTOMERS
--    Goal: Revenue split between first-time vs repeat buyers
-- ============================================================
WITH customer_orders AS (
SELECT
customer_name,
order_id,
order_date,
total_sales,
MIN(order_date) OVER (
PARTITION BY customer_name
) AS first_order_date
FROM sales_data
),
classified_orders AS (
SELECT
customer_name,
order_id,
order_date,
total_sales,
CASE 
WHEN order_date = first_order_date 
THEN 'New Customer Order'
ELSE 'Returning Customer Order'
END AS customer_type
FROM customer_orders
)

SELECT
customer_type,
COUNT(DISTINCT order_id) AS total_orders,
SUM(total_sales)         AS total_revenue
FROM classified_orders
GROUP BY customer_type;

-- ============================================================
-- 7.8 BASKET ANALYSIS (Products frequently bought together)
-- ============================================================
SELECT
s1.product_name AS product_a,
s2.product_name AS product_b,
COUNT(DISTINCT s1.order_id) AS times_bought_together
FROM sales_data s1
JOIN sales_data s2
ON s1.order_id = s2.order_id      -- same order
AND s1.product_name < s2.product_name   -- avoiding duplicates & self-joins
GROUP BY product_a, product_b
HAVING times_bought_together >= 2          -- filtering noise
ORDER BY times_bought_together DESC;

-- ============================================================
-- 7.9 ADVANCED E-COMMERCE KPIs
-- ============================================================

-- 7.9.1 Average Order Value (AOV)
SELECT 
SUM(total_sales)/ COUNT(DISTINCT order_id) AS avg_order_value
FROM sales_data;

-- 7.9.2 Repeat Purchase Rate (RPR)
WITH customer_order_counts AS (
SELECT
customer_name,
COUNT(DISTINCT order_id) AS order_count
FROM sales_data
GROUP BY customer_name
)
SELECT
SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
COUNT(*) AS total_customers,
ROUND(
(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100,
2
) AS repeat_purchase_rate_pct
FROM customer_order_counts;

-- 7.9.3 Cancellation Rate
SELECT
COUNT(*) AS total_orders,
SUM(CASE WHEN LOWER(order_status) = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
ROUND(
(SUM(CASE WHEN LOWER(order_status) = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*)) * 100,
2
) AS cancellation_rate_pct
FROM sales_data;

-- 7.9.4 Payment Method Revenue Share (%)
SELECT
payment_method,
SUM(total_sales) AS total_sales,
ROUND(
(SUM(total_sales) / (SELECT SUM(total_sales) FROM sales_data)) * 100,
2
) AS revenue_share_pct
FROM sales_data
GROUP BY payment_method
ORDER BY total_sales DESC;

-- 7.9.5 Category Revenue Contribution (%)
SELECT
category,
SUM(total_sales) AS total_sales,
ROUND(
(SUM(total_sales) / (SELECT SUM(total_sales) FROM sales_data)) * 100,
2
) AS revenue_contribution_pct
FROM sales_data
GROUP BY category
ORDER BY total_sales DESC;
