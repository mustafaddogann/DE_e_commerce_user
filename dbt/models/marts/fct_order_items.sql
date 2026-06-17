SELECT
    o.order_id,
    o.customer_id,
    oi.order_item_seq,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.purchased_at,
    o.delivered_at,
    oi.shipping_limit_at,
    oi.item_price,
    oi.freight_value,
    oi.item_price + oi.freight_value           AS item_total_value,
    EXTRACT(EPOCH FROM (o.delivered_at - o.purchased_at)) / 86400.0 AS delivery_days
FROM {{ ref('stg_order_items') }} oi
JOIN {{ ref('stg_orders') }}      o  USING (order_id)
