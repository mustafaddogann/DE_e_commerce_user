-- Customer Recency / Frequency / Monetary segmentation.
-- Recency = days since last purchase, relative to the max purchase date in the data.
WITH per_customer AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id)   AS order_count,
        SUM(o.payment_value)         AS lifetime_value,
        MAX(o.purchased_at)          AS last_purchased_at
    FROM {{ ref('fct_orders') }} o
    JOIN {{ ref('dim_customer') }} c USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
),
asof AS (
    SELECT MAX(last_purchased_at)::date AS snapshot_date FROM per_customer
),
scored AS (
    SELECT
        p.customer_unique_id,
        p.order_count,
        ROUND(p.lifetime_value, 2)   AS lifetime_value,
        p.last_purchased_at,
        a.snapshot_date - p.last_purchased_at::date AS recency_days,
        NTILE(5) OVER (ORDER BY a.snapshot_date - p.last_purchased_at::date DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY p.order_count)        AS frequency_score,
        NTILE(5) OVER (ORDER BY p.lifetime_value)     AS monetary_score
    FROM per_customer p, asof a
)
SELECT
    *,
    recency_score + frequency_score + monetary_score AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'champions'
        WHEN recency_score >= 4 AND frequency_score <= 2                          THEN 'new_customers'
        WHEN recency_score <= 2 AND frequency_score >= 4                          THEN 'at_risk_loyal'
        WHEN recency_score <= 2 AND monetary_score >= 4                           THEN 'cant_lose'
        WHEN recency_score <= 2                                                   THEN 'hibernating'
        ELSE 'others'
    END AS segment
FROM scored
