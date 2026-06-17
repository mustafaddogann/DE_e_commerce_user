SELECT
    seller_id,
    seller_zip_code_prefix::text   AS seller_zip_code_prefix,
    NULLIF(TRIM(seller_city), '')  AS seller_city,
    NULLIF(TRIM(seller_state), '') AS seller_state
FROM {{ source('bronze', 'sellers') }}
