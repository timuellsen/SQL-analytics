-- Which product categories generate  the highest revenue?
SELECT
	pr.product_category_name,
	COUNT(*) AS items_sold,
	COUNT(DISTINCT oi.order_id) AS num_orders,
	ROUND(SUM(oi.price), 2) AS category_revenue
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE pr.product_category_name IS NOT NULL
GROUP BY pr.product_category_name
ORDER BY category_revenue DESC
LIMIT 5;
