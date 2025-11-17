SELECT
s1.product_name AS product_a,
s2.product_name AS product_b,
COUNT(DISTINCT s1.order_id) AS times_bought_together
FROM sales_data s1
JOIN sales_data s2
ON s1.order_id = s2.order_id      -- same order
AND s1.product_name < s2.product_name   -- avoiding duplicates & self-joins
GROUP BY product_a, product_b
HAVING times_bought_together >= 2          -- filtering noise
ORDER BY times_bought_together DESC;
