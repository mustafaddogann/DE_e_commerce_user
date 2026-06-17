WITH p AS (
    SELECT
        product_id,
        NULLIF(TRIM(product_category_name), '') AS category_pt,
        product_name_lenght::int           AS product_name_length,
        product_description_lenght::int    AS product_description_length,
        product_photos_qty::int            AS product_photos_qty,
        product_weight_g::int              AS product_weight_g,
        product_length_cm::int             AS product_length_cm,
        product_height_cm::int             AS product_height_cm,
        product_width_cm::int              AS product_width_cm
    FROM {{ source('bronze', 'products') }}
)
SELECT
    p.*,
    NULLIF(TRIM(t.product_category_name_english), '') AS category_en
FROM p
LEFT JOIN {{ source('bronze', 'product_category_translation') }} t
       ON p.category_pt = t.product_category_name
