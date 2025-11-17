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
