
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

