-- STEP 2: Build clean_orders from raw_orders
-- Rules: 'NaN' text -> NULL | impossible values -> NULL (rows are kept) | text prefixes removed

DROP TABLE IF EXISTS clean_orders;

CREATE TABLE clean_orders AS
WITH step1 AS (
  SELECT
    TRIM(ID)                          AS order_id,
    TRIM(Delivery_person_ID)          AS partner_id,

    -- age: NaN or under 18 -> NULL
    CASE WHEN TRIM(Delivery_person_Age) = 'NaN' THEN NULL
         WHEN CAST(TRIM(Delivery_person_Age) AS INTEGER) < 18 THEN NULL
         ELSE CAST(TRIM(Delivery_person_Age) AS INTEGER) END      AS partner_age,

    -- rating: NaN or above 5 -> NULL
    CASE WHEN TRIM(Delivery_person_Ratings) = 'NaN' THEN NULL
         WHEN CAST(TRIM(Delivery_person_Ratings) AS REAL) > 5 THEN NULL
         ELSE CAST(TRIM(Delivery_person_Ratings) AS REAL) END     AS partner_rating,

    -- coordinates: 0,0 restaurant = missing location
    CASE WHEN ABS(CAST(Restaurant_latitude AS REAL)) < 1 THEN NULL
         ELSE CAST(Restaurant_latitude AS REAL) END               AS restaurant_lat,
    CASE WHEN ABS(CAST(Restaurant_latitude AS REAL)) < 1 THEN NULL
         ELSE CAST(Restaurant_longitude AS REAL) END              AS restaurant_lon,
    CASE WHEN ABS(CAST(Restaurant_latitude AS REAL)) < 1 THEN NULL
         ELSE CAST(Delivery_location_latitude AS REAL) END        AS delivery_lat,
    CASE WHEN ABS(CAST(Restaurant_latitude AS REAL)) < 1 THEN NULL
         ELSE CAST(Delivery_location_longitude AS REAL) END       AS delivery_lon,

    -- DD-MM-YYYY -> YYYY-MM-DD
    SUBSTR(TRIM(Order_Date),7,4) || '-' || SUBSTR(TRIM(Order_Date),4,2) || '-' || SUBSTR(TRIM(Order_Date),1,2) AS order_date,

    CASE WHEN TRIM(Time_Orderd) = 'NaN' THEN NULL ELSE TRIM(Time_Orderd) END AS order_time,
    TRIM(Time_Order_picked)           AS pickup_time,

    CASE WHEN TRIM(Weatherconditions) = 'conditions NaN' THEN NULL
         ELSE TRIM(REPLACE(Weatherconditions,'conditions ','')) END AS weather,
    CASE WHEN TRIM(Road_traffic_density) = 'NaN' THEN NULL ELSE TRIM(Road_traffic_density) END AS traffic,
    CAST(Vehicle_condition AS INTEGER) AS vehicle_condition,
    TRIM(Type_of_order)               AS order_type,
    TRIM(Type_of_vehicle)             AS vehicle_type,
    CASE WHEN TRIM(multiple_deliveries) = 'NaN' THEN NULL ELSE CAST(TRIM(multiple_deliveries) AS INTEGER) END AS multiple_deliveries,
    CASE WHEN TRIM(Festival) = 'NaN' THEN NULL ELSE TRIM(Festival) END AS festival,
    CASE WHEN TRIM(City) = 'NaN' THEN NULL ELSE TRIM(City) END AS city,

    -- '(min) 24' -> 24
    CAST(TRIM(REPLACE("Time_taken(min)",'(min)','')) AS INTEGER)  AS delivery_time_min
  FROM raw_orders
)
SELECT
  *,
  -- hour of day the order was placed
  CASE WHEN order_time IS NULL THEN NULL ELSE CAST(SUBSTR(order_time,1,2) AS INTEGER) END AS order_hour,
  -- minutes between order and pickup (+1440 handles orders that cross midnight)
  CASE WHEN order_time IS NULL THEN NULL
       ELSE ((CAST(SUBSTR(pickup_time,1,2) AS INTEGER)*60 + CAST(SUBSTR(pickup_time,4,2) AS INTEGER))
           - (CAST(SUBSTR(order_time,1,2)  AS INTEGER)*60 + CAST(SUBSTR(order_time,4,2)  AS INTEGER)) + 1440) % 1440
  END AS pickup_wait_min
FROM step1;

-- Checks
SELECT COUNT(*) AS rows_kept FROM clean_orders;                                   -- expect 45593
SELECT MIN(delivery_time_min), MAX(delivery_time_min), ROUND(AVG(delivery_time_min),1) FROM clean_orders;
SELECT pickup_wait_min, COUNT(*) FROM clean_orders GROUP BY 1 ORDER BY 1;
