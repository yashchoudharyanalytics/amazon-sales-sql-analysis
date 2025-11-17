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
