SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix::text   AS customer_zip_code_prefix,
    NULLIF(TRIM(customer_city), '')  AS customer_city,
    NULLIF(TRIM(customer_state), '') AS customer_state
FROM {{ source('bronze', 'customers') }}
