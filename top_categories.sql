-- Which product categories generate  the highest revenue?
SELECT
	pr.product_category_name,
	COUNT(DISTINCT oi.order_id) AS items_sold,
	ROUND(SUM(p.payment_value), 2) AS category_revenue
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
JOIN payments p ON oi.order_id = p.order_id
WHERE pr.product_category_name IS NOT NULL
GROUP BY pr.product_category_name
ORDER BY category_revenue DESC
LIMIT 5;