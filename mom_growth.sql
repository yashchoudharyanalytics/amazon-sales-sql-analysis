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
