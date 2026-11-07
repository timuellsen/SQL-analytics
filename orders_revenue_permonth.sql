-- How does revenue and number of orders develop from month to month?
SELECT
	strftime('%m-%Y', o.order_purchase_timestamp) AS order_month,
	COUNT(DISTINCT o.order_id) AS total_orders,
	ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month ASC;