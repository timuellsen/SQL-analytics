WITH ref AS (
	-- Reference date = latest delivered order in the dataset
    SELECT MAX(order_purchase_timestamp) AS max_ts
    FROM orders
    WHERE order_status = 'delivered'
),
customer_metrics AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(SUM(p.payment_value), 2) AS total_spent,
        MAX(o.order_purchase_timestamp) AS last_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
scored AS (
    SELECT 
        m.*,
        CAST(julianday(r.max_ts) - julianday(m.last_order) AS INTEGER) AS recency_days
    FROM customer_metrics m
    CROSS JOIN ref r
),
rfm AS (
    SELECT 
        customer_unique_id,
        recency_days,
        order_count,
        total_spent,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,  -- 4 = most recent purchase
        CASE WHEN order_count >= 3 THEN 3
             WHEN order_count = 2  THEN 2
             ELSE 1 END AS f_score,								-- fixed tiers (most customers order once)
        NTILE(4) OVER (ORDER BY total_spent ASC) AS m_score     -- 4 = highest spend
    FROM scored
),
segmented AS (
    SELECT 
        customer_unique_id,
        total_spent,
        CASE 
			WHEN f_score >= 2                  THEN 'Repeat customers'
            WHEN r_score >= 3 AND m_score >= 3 THEN 'Top customers'
            WHEN r_score >= 3 AND m_score <= 2 THEN 'Recent, low spend'
            WHEN r_score <= 2 AND m_score >= 3 THEN 'At risk, high spend'
            ELSE 'Inactive'
        END AS segment
    FROM rfm
)
SELECT 
    segment,
    COUNT(*)                                                     AS customers,
    ROUND(AVG(total_spent), 2)                                   AS avg_spend,
    ROUND(SUM(total_spent), 2)                                   AS total_revenue,
    ROUND(100.0 * SUM(total_spent) / (SELECT SUM(total_spent) FROM segmented), 1) AS revenue_share_pct
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;
