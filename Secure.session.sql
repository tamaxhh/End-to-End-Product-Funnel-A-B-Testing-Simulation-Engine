show databases;


SELECT
    event_type,
    COUNT(*) AS event_count
FROM product_analytics.A_B_testing_data
GROUP BY event_type
ORDER BY event_count DESC;

