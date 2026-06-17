WITH per_seller AS (
    SELECT
        s.seller_id,
        s.seller_state,
        s.seller_city,
        COUNT(DISTINCT oi.order_id)    AS order_count,
        COUNT(*)                       AS line_item_count,
        SUM(oi.item_price)             AS gross_revenue,
        AVG(oi.delivery_days)          AS avg_delivery_days
    FROM {{ ref('fct_order_items') }} oi
    JOIN {{ ref('dim_seller') }}     s USING (seller_id)
    GROUP BY s.seller_id, s.seller_state, s.seller_city
),
review_per_seller AS (
    SELECT
        oi.seller_id,
        AVG(o.review_score)::numeric(3, 2) AS avg_review_score
    FROM {{ ref('fct_order_items') }} oi
    JOIN {{ ref('fct_orders') }}     o  USING (order_id)
    WHERE o.review_score IS NOT NULL
    GROUP BY oi.seller_id
)
SELECT
    ps.seller_id,
    ps.seller_state,
    ps.seller_city,
    ps.order_count,
    ps.line_item_count,
    ROUND(ps.gross_revenue, 2)          AS gross_revenue,
    ROUND(ps.avg_delivery_days::numeric, 2) AS avg_delivery_days,
    rs.avg_review_score
FROM per_seller ps
LEFT JOIN review_per_seller rs USING (seller_id)
