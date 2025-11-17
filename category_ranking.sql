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
