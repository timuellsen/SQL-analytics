-- Reconciliation: payments vs. item price + freight (delivered orders only)
WITH paid AS (
    SELECT o.order_id, SUM(p.payment_value) AS paid
    FROM orders o JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
),
items AS (
    SELECT oi.order_id, SUM(oi.price + oi.freight_value) AS item_total
    FROM order_items oi
    GROUP BY oi.order_id
)
SELECT 
    ROUND(SUM(paid.paid), 2)       AS total_paid,
    ROUND(SUM(items.item_total), 2) AS total_items_plus_freight,
    ROUND(100.0 * (SUM(paid.paid) - SUM(items.item_total)) / SUM(items.item_total), 2) AS diff_pct,
    SUM(CASE WHEN ABS(paid.paid - items.item_total) > 1 THEN 1 ELSE 0 END) AS orders_with_diff_over_1
FROM paid
JOIN items ON paid.order_id = items.order_id;