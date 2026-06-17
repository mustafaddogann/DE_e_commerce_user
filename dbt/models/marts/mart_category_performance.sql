SELECT
    p.product_category,
    COUNT(DISTINCT oi.order_id)         AS order_count,
    COUNT(*)                            AS line_item_count,
    SUM(oi.item_price)                  AS gross_revenue,
    SUM(oi.freight_value)               AS freight_revenue,
    AVG(oi.item_price)::numeric(12, 2)  AS avg_price,
    AVG(oi.delivery_days)::numeric(6, 2) AS avg_delivery_days
FROM {{ ref('fct_order_items') }} oi
JOIN {{ ref('dim_product') }}    p USING (product_id)
GROUP BY p.product_category
