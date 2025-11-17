-- Monthly category sales with cumulative & 3-month moving avg
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
