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
