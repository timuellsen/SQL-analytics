-- Data quality checks (SQLite): one row per check
SELECT '01 rows in orders' AS check_name, COUNT(*) AS result FROM orders
UNION ALL
SELECT '02 duplicate order_ids in orders',
       COUNT(*) FROM (SELECT order_id FROM orders GROUP BY order_id HAVING COUNT(*) > 1)
UNION ALL
SELECT '03 duplicate customer_ids in customers',
       COUNT(*) FROM (SELECT customer_id FROM customers GROUP BY customer_id HAVING COUNT(*) > 1)
UNION ALL
SELECT '04 duplicate product_ids in products',
       COUNT(*) FROM (SELECT product_id FROM products GROUP BY product_id HAVING COUNT(*) > 1)
UNION ALL
SELECT '05 order_items without matching order',
       COUNT(*) FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id
       WHERE o.order_id IS NULL
UNION ALL
SELECT '06 order_items without matching product',
       COUNT(*) FROM order_items oi LEFT JOIN products pr ON oi.product_id = pr.product_id
       WHERE pr.product_id IS NULL
UNION ALL
SELECT '07 delivered orders without payment',
       COUNT(*) FROM orders o LEFT JOIN payments p ON o.order_id = p.order_id
       WHERE o.order_status = 'delivered' AND p.order_id IS NULL
UNION ALL
SELECT '08 delivered orders without items',
       COUNT(*) FROM orders o LEFT JOIN order_items oi ON o.order_id = oi.order_id
       WHERE o.order_status = 'delivered' AND oi.order_id IS NULL
UNION ALL
SELECT '09 products without category',
       COUNT(*) FROM products WHERE product_category_name IS NULL
UNION ALL
SELECT '10 payments with value <= 0',
       COUNT(*) FROM payments WHERE payment_value <= 0
UNION ALL
SELECT '11 items with price <= 0',
       COUNT(*) FROM order_items WHERE price <= 0
UNION ALL
SELECT '12 delivered orders without delivery date',
       COUNT(*) FROM orders
       WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;