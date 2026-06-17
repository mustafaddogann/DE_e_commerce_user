SELECT
    order_id,
    order_item_id::int       AS order_item_seq,
    product_id,
    seller_id,
    shipping_limit_date::timestamp AS shipping_limit_at,
    price::numeric(12, 2)    AS item_price,
    freight_value::numeric(12, 2) AS freight_value
FROM {{ source('bronze', 'order_items') }}
