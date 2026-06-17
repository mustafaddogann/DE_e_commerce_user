SELECT
    product_id,
    COALESCE(category_en, category_pt) AS product_category,
    category_pt                        AS product_category_pt,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM {{ ref('stg_products') }}
