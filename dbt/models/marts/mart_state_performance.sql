SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)        AS order_count,
    COUNT(DISTINCT o.customer_id)     AS customer_count,
    SUM(o.payment_value)::numeric(14, 2) AS total_revenue,
    AVG(o.payment_value)::numeric(12, 2) AS avg_order_value,
    AVG(o.delivery_days)::numeric(6, 2)  AS avg_delivery_days,
    AVG(o.review_score)::numeric(3, 2)   AS avg_review_score
FROM {{ ref('fct_orders') }} o
JOIN {{ ref('dim_customer') }} c USING (customer_id)
GROUP BY c.customer_state
