-- STEP 3: Analysis queries (table: clean_orders)

-- Q1. Which traffic + weather combinations are slowest? (min 100 orders so averages are reliable)
WITH combo AS (
  SELECT traffic, weather, COUNT(*) AS orders, ROUND(AVG(delivery_time_min),1) AS avg_min
  FROM clean_orders
  WHERE traffic IS NOT NULL AND weather IS NOT NULL
  GROUP BY traffic, weather
  HAVING COUNT(*) >= 100
)
SELECT traffic, weather, orders, avg_min,
       RANK() OVER (ORDER BY avg_min DESC) AS slowest_rank
FROM combo
ORDER BY slowest_rank
LIMIT 10;

-- Q2. Which hours are slowest? Compare each hour with the overall average
SELECT order_hour, COUNT(*) AS orders,
       ROUND(AVG(delivery_time_min),1) AS avg_min,
       ROUND(AVG(delivery_time_min) - (SELECT AVG(delivery_time_min) FROM clean_orders),1) AS vs_overall
FROM clean_orders
WHERE order_hour IS NOT NULL
GROUP BY order_hour
ORDER BY order_hour;

-- Q3. Do higher-rated partners deliver faster?
SELECT CASE WHEN partner_rating >= 4.8 THEN '4.8-5.0'
            WHEN partner_rating >= 4.5 THEN '4.5-4.7'
            WHEN partner_rating >= 4.0 THEN '4.0-4.4'
            ELSE 'Below 4.0' END AS rating_band,
       COUNT(*) AS orders, ROUND(AVG(delivery_time_min),1) AS avg_min
FROM clean_orders
WHERE partner_rating IS NOT NULL
GROUP BY rating_band
ORDER BY rating_band DESC;

-- Q4. Do multiple deliveries at once slow things down?
SELECT multiple_deliveries, COUNT(*) AS orders, ROUND(AVG(delivery_time_min),1) AS avg_min
FROM clean_orders
WHERE multiple_deliveries IS NOT NULL
GROUP BY multiple_deliveries
ORDER BY multiple_deliveries;

-- Q5. Vehicle type and vehicle condition
SELECT vehicle_type, COUNT(*) AS orders, ROUND(AVG(delivery_time_min),1) AS avg_min
FROM clean_orders GROUP BY vehicle_type ORDER BY avg_min;

SELECT vehicle_condition, COUNT(*) AS orders, ROUND(AVG(delivery_time_min),1) AS avg_min
FROM clean_orders GROUP BY vehicle_condition ORDER BY vehicle_condition;

-- Q6. Festival effect
SELECT festival, COUNT(*) AS orders, ROUND(AVG(delivery_time_min),1) AS avg_min
FROM clean_orders WHERE festival IS NOT NULL
GROUP BY festival;
