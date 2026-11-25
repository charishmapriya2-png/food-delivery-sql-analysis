-- STEP 1: Profile the raw data (table: raw_orders, every column loaded as text)

-- 1.1 Row count and unique order IDs
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT TRIM(ID)) AS unique_ids FROM raw_orders;

-- 1.2 Hidden missing values: 'NaN ' is stored as TEXT (with a trailing space), so IS NULL finds nothing
SELECT
  SUM(TRIM(Delivery_person_Age)      = 'NaN') AS age_missing,
  SUM(TRIM(Delivery_person_Ratings)  = 'NaN') AS rating_missing,
  SUM(TRIM(Time_Orderd)              = 'NaN') AS order_time_missing,
  SUM(TRIM(multiple_deliveries)      = 'NaN') AS multi_delivery_missing,
  SUM(TRIM(Weatherconditions)        = 'conditions NaN') AS weather_missing,
  SUM(TRIM(Road_traffic_density)     = 'NaN') AS traffic_missing,
  SUM(TRIM(Festival)                 = 'NaN') AS festival_missing,
  SUM(TRIM(City)                     = 'NaN') AS city_missing
FROM raw_orders;

-- 1.3 Text clutter: prefixes and extra spaces
SELECT DISTINCT Weatherconditions FROM raw_orders;      -- 'conditions Sunny' -> 'Sunny'
SELECT DISTINCT Time_taken_min_sample FROM (
  SELECT "Time_taken(min)" AS Time_taken_min_sample FROM raw_orders LIMIT 5);  -- '(min) 24' -> 24

-- 1.4 Impossible values
SELECT COUNT(*) AS rating_above_5 FROM raw_orders
WHERE TRIM(Delivery_person_Ratings) <> 'NaN' AND CAST(Delivery_person_Ratings AS REAL) > 5;
SELECT COUNT(*) AS age_below_18 FROM raw_orders
WHERE TRIM(Delivery_person_Age) <> 'NaN' AND CAST(Delivery_person_Age AS INTEGER) < 18;
SELECT COUNT(*) AS zero_coordinates FROM raw_orders
WHERE ABS(CAST(Restaurant_latitude AS REAL)) < 1;

-- 1.5 Time logic: food picked up BEFORE it was ordered (crosses midnight or bad data)
SELECT COUNT(*) AS picked_before_ordered FROM raw_orders
WHERE TRIM(Time_Orderd) <> 'NaN' AND Time_Order_picked < Time_Orderd;

-- 1.6 Orders per month (dates are text in DD-MM-YYYY format)
SELECT SUBSTR(Order_Date,4,7) AS month, COUNT(*) AS orders FROM raw_orders GROUP BY 1 ORDER BY 1;
