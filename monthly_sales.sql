SELECT DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
       SUM(total_sales) AS monthly_sales
FROM sales_data
GROUP BY month_start
ORDER BY month_start;

