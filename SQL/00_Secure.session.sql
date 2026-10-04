show databases;


SELECT
    event_type,
    COUNT(*) AS event_count
FROM product_analytics.A_B_testing_data
GROUP BY event_type
ORDER BY event_count DESC;

SELECT event_time FROM product_analytics.A_B_testing_data LIMIT 5;

ALTER TABLE product_analytics.A_B_testing_data 
MODIFY COLUMN event_time DATETIME;