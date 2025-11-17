-- Customer summary: spend, frequency, avg order value
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
-- Spend-based segmentation (High, Medium, Low value customers)
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
