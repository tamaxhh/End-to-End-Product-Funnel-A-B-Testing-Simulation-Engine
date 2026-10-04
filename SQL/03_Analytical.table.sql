-- Session-level analytical table

CREATE SCHEMA IF NOT EXISTS product_analytics;

CREATE TABLE IF NOT EXISTS product_analytics.session_metrics (
    user_session VARCHAR(64) NOT NULL,
    user_id BIGINT NOT NULL,
    session_start DATETIME,
    session_end DATETIME,
    session_duration_seconds INT,
    viewed INT DEFAULT 0,
    added_to_cart INT DEFAULT 0,
    removed_from_cart INT DEFAULT 0,
    purchased INT DEFAULT 0,
    revenue DECIMAL(12, 2) DEFAULT 0.00,
    product_count INT DEFAULT 0,
    PRIMARY KEY (user_session, user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_session_start (session_start)
) ENGINE=InnoDB;

-- Insert session metrics into the table

INSERT INTO product_analytics.session_metrics (
    user_session,
    user_id,
    session_start,
    session_end,
    session_duration_seconds,
    viewed,
    added_to_cart,
    removed_from_cart,
    purchased,
    revenue,
    product_count
)
SELECT 
    user_session,
    user_id,
    MIN(event_time) AS session_start,
    MAX(event_time) AS session_end,
    TIMESTAMPDIFF(SECOND, MIN(event_time), MAX(event_time)) AS session_duration_seconds,
    
    -- Event counts per session
    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
    SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
    SUM(CASE WHEN event_type = 'remove_from_cart' THEN 1 ELSE 0 END) AS removed_from_cart,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased,
    
    -- Revenue only from completed purchases
    COALESCE(SUM(CASE WHEN event_type = 'purchase' THEN price ELSE 0 END), 0.00) AS revenue,
    
    -- Unique products interacted with during the session
    COUNT(DISTINCT product_id) AS product_count

FROM product_analytics.A_B_testing_data
WHERE user_session IS NOT NULL
GROUP BY 
    user_session, 
    user_id;

-- verifying the inserted data

SELECT 
    user_session,
    user_id,  
    session_start,
    session_duration_seconds,
    viewed,
    added_to_cart,
    purchased,
    revenue,
    product_count
FROM product_analytics.session_metrics
ORDER BY session_start DESC;
