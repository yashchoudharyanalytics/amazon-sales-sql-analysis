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
