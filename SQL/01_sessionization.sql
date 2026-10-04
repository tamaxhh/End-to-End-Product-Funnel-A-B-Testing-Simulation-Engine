CREATE INDEX idx_user_event_time 
ON product_analytics.A_B_testing_data (user_id, event_time);

-- 

CREATE TABLE product_analytics.sessionized_events AS
WITH event_lags AS (
    SELECT
        user_id,
        event_time,
        event_type,
        user_session,
        LAG(event_time) OVER (
            PARTITION BY user_id
            ORDER BY event_time
        ) AS previous_event_time
    FROM product_analytics.A_B_testing_data
),
session_flags AS (
    SELECT
        user_id,
        event_time,
        event_type,
        user_session,
        CASE
            WHEN previous_event_time IS NULL THEN 1
            WHEN TIMESTAMPDIFF(MINUTE, previous_event_time, event_time) > 30 THEN 1
            ELSE 0
        END AS new_session
    FROM event_lags
)
SELECT
    user_id,
    event_time,
    event_type,
    user_session,
    SUM(new_session) OVER (
        PARTITION BY user_id
        ORDER BY event_time
        ROWS UNBOUNDED PRECEDING
    ) AS calculated_session_id
FROM session_flags;

--

SELECT *
FROM sessionized
LIMIT 1000;

--

CREATE INDEX idx_user_session 
ON product_analytics.sessionized_events (user_id, calculated_session_id);