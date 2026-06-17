SELECT
    review_id,
    order_id,
    review_score::int                 AS review_score,
    NULLIF(TRIM(review_comment_title), '')   AS review_title,
    NULLIF(TRIM(review_comment_message), '') AS review_message,
    review_creation_date::timestamp   AS reviewed_at,
    review_answer_timestamp::timestamp AS answered_at
FROM {{ source('bronze', 'order_reviews') }}
