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
