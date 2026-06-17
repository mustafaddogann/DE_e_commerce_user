WITH items AS (
    SELECT
        order_id,
        COUNT(*)              AS item_count,
        SUM(item_price)       AS items_value,
        SUM(freight_value)    AS freight_value,
        SUM(item_price + freight_value) AS order_total_value
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),
payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value,
        MAX(payment_installments) AS max_installments
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
),
reviews AS (
    SELECT
        order_id,
        AVG(review_score)::numeric(3, 2) AS review_score,
        COUNT(*)                         AS review_count
    FROM {{ ref('stg_order_reviews') }}
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.purchased_at,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,
    COALESCE(i.item_count, 0)           AS item_count,
    COALESCE(i.items_value, 0)          AS items_value,
    COALESCE(i.freight_value, 0)        AS freight_value,
    COALESCE(i.order_total_value, 0)    AS order_total_value,
    COALESCE(p.payment_value, 0)        AS payment_value,
    p.max_installments,
    r.review_score,
    COALESCE(r.review_count, 0)         AS review_count,
    CASE WHEN o.delivered_at IS NOT NULL
         THEN EXTRACT(EPOCH FROM (o.delivered_at - o.purchased_at)) / 86400.0
    END                                  AS delivery_days,
    CASE WHEN o.delivered_at IS NOT NULL AND o.estimated_delivery_at IS NOT NULL
         THEN EXTRACT(EPOCH FROM (o.delivered_at - o.estimated_delivery_at)) / 86400.0
    END                                  AS days_late
FROM {{ ref('stg_orders') }} o
LEFT JOIN items    i ON o.order_id = i.order_id
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews  r ON o.order_id = r.order_id
