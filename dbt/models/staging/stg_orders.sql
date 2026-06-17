SELECT
    order_id,
    customer_id,
    NULLIF(TRIM(order_status), '')        AS order_status,
    order_purchase_timestamp::timestamp   AS purchased_at,
    order_approved_at::timestamp          AS approved_at,
    order_delivered_carrier_date::timestamp AS shipped_at,
    order_delivered_customer_date::timestamp AS delivered_at,
    order_estimated_delivery_date::timestamp AS estimated_delivery_at
FROM {{ source('bronze', 'orders') }}
