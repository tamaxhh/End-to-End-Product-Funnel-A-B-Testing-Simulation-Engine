WITH session_funnel AS (

    SELECT
        user_session,

        MAX(
            CASE
                WHEN event_type = 'view'
                THEN 1 ELSE 0
            END
        ) AS viewed,

        MAX(
            CASE
                WHEN event_type = 'cart'
                THEN 1 ELSE 0
            END
        ) AS added_to_cart,

        MAX(
            CASE
                WHEN event_type = 'purchase'
                THEN 1 ELSE 0
            END
        ) AS purchased

    FROM product_analytics.a_b_testing_data

    GROUP BY user_session
)

SELECT

    SUM(viewed) AS view_sessions,

    SUM(added_to_cart) AS cart_sessions,

    SUM(purchased) AS purchase_sessions,

    ROUND(
        100.0 * SUM(added_to_cart)
        / NULLIF(SUM(viewed), 0),
        2
    ) AS view_to_cart_rate,

    ROUND(
        100.0 * SUM(purchased)
        / NULLIF(SUM(added_to_cart), 0),
        2
    ) AS cart_to_purchase_rate,

    ROUND(
        100.0 * SUM(purchased)
        / NULLIF(SUM(viewed), 0),
        2
    ) AS overall_conversion_rate

FROM session_funnel;