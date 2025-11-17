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
