# Food Delivery Time Analysis with SQL

An end-to-end SQL project that cleans a messy Indian food delivery dataset (45,593 orders) and finds what makes deliveries slow.

## Business Questions
1. Which traffic and weather conditions slow deliveries the most?
2. Which hours of the day are slowest?
3. Do higher-rated delivery partners deliver faster?
4. Does carrying multiple orders at once slow delivery?
5. Does vehicle type or vehicle condition matter?
6. How much do festivals affect delivery time?

## Dataset
Kaggle "Food Delivery Dataset"  https://www.kaggle.com/datasets/gauravmalik26/food-delivery-dataset (`train.csv`): 45,593 orders from March to April 2022 (mostly March), with partner age and rating, weather, traffic, vehicle details, city type, festival flag and delivery time in minutes. *(Add the Kaggle link here.)*

## Tools
SQL (SQLite / DB Browser for SQLite): CTEs, window functions (`RANK`), `CASE`, aggregations, type casting, string cleaning.

## Data Cleaning (`02_clean_data.sql`)
The raw data stored every value as text. I built a `clean_orders` table that:
- converted hidden missing values (`'NaN '` text with a trailing space) to real NULLs
- removed text prefixes (`conditions Sunny` to `Sunny`, `(min) 24` to `24`)
- set impossible values to NULL and kept the rows (53 ratings above 5, 38 partners aged 15)
- set 3,640 rows with 0,0 restaurant coordinates to NULL
- converted DD-MM-YYYY text dates to YYYY-MM-DD
- added `order_hour` and `pickup_wait_min` (handling orders that cross midnight)

All 45,593 rows were kept.

## Key Findings (average delivery time; overall average 26.3 min)
| Question | Finding |
|---|---|
| Traffic + weather | Jam traffic with Fog or Cloudy weather is slowest at about 36.7 min, around 10 min above average |
| Time of day | Evenings 7-9 pm are slowest (30.8-31.2 min); mornings 8-10 am are fastest (about 19.5 min) |
| Partner rating | Partners rated below 4.0 average 36.8 min vs 24.2-24.4 min for ratings of 4.5 and above |
| Multiple deliveries | 0 extra orders: 22.9 min; 1: 26.9; 2: 40.5; 3: 47.8 |
| Festivals | Festival days average 45.5 min vs 26.0 on normal days (only 896 festival orders) |

## Recommendations
- Limit how many orders one partner carries at a time, especially in evening peaks. Delivery time roughly doubles at 3 simultaneous orders.
- Add partner capacity between 7 and 9 pm and on festival days.
- Review training and routing support for partners rated below 4.0.
- Warn customers about longer waits in jam traffic with fog or cloud.

## Limitations
- These are patterns in the data, not proof of cause. Morning speed may partly reflect low traffic.
- Some groups are small (festival days, bicycles, semi-urban areas), so treat them with caution.
- About 4% of orders have no restaurant location, so distance-based analysis was not done.

## Files
| File | Purpose |
|---|---|
| `01_profile_raw_data.sql` | Data quality checks |
| `02_clean_data.sql` | Builds `clean_orders` |
| `03_analysis.sql` | The six analysis queries |
