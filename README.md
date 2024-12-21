# goodcabs Ad-Hoc Requests 
SQL CODES


REQUEST 1

Generate a report that displays the total trips, average fare per km, average fare per trip, and the percentage contribution of each city's trips to the overall trips. This report will help in assessing trip volume, pricing efficiency, and each city's contribution to the overall trip count.
Fields:
city_name
total_trips
avg_fare_per_km
avg_fare_per_trip
%_contribution_to_total_trips

SQL QUERY

WITH cte1 AS (
    SELECT 
        city_id,
        COUNT(trip_id) AS total_trips,
        SUM(fare_amount) AS total_fare,
        SUM(distance_travelled_km) AS total_dis_travel_km
    FROM 
        trips_db.fact_trips
    GROUP BY 
        city_id
)

SELECT 
    city_name,
    city_id,
    total_trips,
    ROUND(total_fare / total_dis_travel_km, 2) AS avg_fare_per_km,
    ROUND(total_fare / total_trips, 2) AS avg_fare_per_trip,
    ROUND(total_trips / (SELECT COUNT(trip_id) FROM trips_db.fact_trips) * 100, 2) AS per_contribution_to_total_trips
FROM 
    cte1
JOIN 
    dim_city USING (city_id);



REQUEST 2

Generate a report that evaluates the target performance for trips at the monthly and city level. For each city and month, compare the actual total trips with the target trips and categorise the performance as follows:
If actual trips are greater than target trips, mark it as "Above Target".
If actual trips are less than or equal to target trips, mark it as "Below Target".
Additionally, calculate the % difference between actual and target trips to quantify the performance gap.
Fields:
city_name
month_name
actual_trips
target_trips
performance_status
%_difference



SQL QUERY

WITH actuals AS (
    SELECT 
        f.city_id,
        start_of_month,
        COUNT(trip_id) AS actual_trips
    FROM trips_db.fact_trips f
    JOIN dim_date d USING (date)
    GROUP BY city_id, start_of_month
),

target AS (
    SELECT 
        DISTINCT city_id,
        start_of_month,
        total_target_trips AS target_trips
    FROM targets_db.monthly_target_trips t
    JOIN dim_date d ON d.start_of_month = t.month
)

SELECT 
    city_name,
    MONTHNAME(start_of_month) AS month,
    actual_trips,
    target_trips,
    IF(target_trips > actual_trips, "Below Target", "Above Target") AS performance_status,
    ROUND((actual_trips - target_trips) / target_trips * 100, 2) AS percentage_difference
FROM actuals
JOIN target USING (city_id, start_of_month)
JOIN dim_city USING (city_id)
ORDER BY start_of_month, city_name;





REQUEST 3

Generate a report that shows the percentage distribution of repeat passengers by the number of trips they have taken in each city. Calculate the percentage of repeat passengers who took 2 trips, 3 trips, and so on, up to 10 trips.
Each column should represent a trip count category, displaying the percentage of repeat passengers who fall into that category out of the total repeat passengers for that city.
This report will help identify cities with high repeat trip frequency, which can indicate strong customer loyalty or frequent usage patterns.
Fields:
city_name
2-Trips, 3-Trips, 4-Trips, 5-Trips, 6-Trips, 7-Trips, 8-Trips, 9-Trips, 10-Trips




SQL QUERY

WITH total_repeat_pass AS (
    SELECT city_id, SUM(repeat_passenger_count) AS total_repeat_pass
    FROM trips_db.dim_repeat_trip_distribution
    GROUP BY city_id
)

SELECT 
    city_id,
    SUM(CASE WHEN trip_count = '2-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `2_trips`,
    SUM(CASE WHEN trip_count = '3-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `3_trips`,
    SUM(CASE WHEN trip_count = '4-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `4_trips`,
    SUM(CASE WHEN trip_count = '5-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `5_trips`,
    SUM(CASE WHEN trip_count = '6-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `6_trips`,
    SUM(CASE WHEN trip_count = '7-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `7_trips`,
    SUM(CASE WHEN trip_count = '8-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `8_trips`,
    SUM(CASE WHEN trip_count = '9-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `9_trips`,
    SUM(CASE WHEN trip_count = '10-trips' THEN ROUND(repeat_passenger_count / total_repeat_pass * 100, 2) ELSE 0 END) AS `10_trips`
FROM trips_db.dim_repeat_trip_distribution
JOIN total_repeat_pass USING (city_id)
GROUP BY city_id;


REQUEST 4

Generate a report that calculates the total new passengers for each city and ranks them based on this value. Identify the top 3 cities with the highest number of new passengers as well as the bottom 3 cities with the lowest number of new passengers, categorising them as "Top 3" or "Bottom 3" accordingly.

Fields:
city_name
total_new_passengers
city_category ("Top 3" or "Bottom 3"



SQL QUERY

WITH cte1 AS (
    SELECT 
        city_id,
        SUM(new_passengers) AS new_passengers,
        DENSE_RANK() OVER (ORDER BY SUM(new_passengers) DESC) AS rnk
    FROM trips_db.fact_passenger_summary
    GROUP BY city_id
)

SELECT 
    city_name,
    new_passengers,
    CASE WHEN rnk <= 3 THEN 'Top 3'
         WHEN rnk >= 8 THEN 'Bottom 3'
         ELSE '' END AS city_category
FROM cte1
JOIN dim_city USING (city_id)
WHERE rnk IN (1, 2, 3, 8, 9, 10);


REQUEST 5

Generate a report that identifies the month with the highest revenue for each city. For each city, display the month_name, the revenue amount for that month, and the percentage contribution of that month's revenue to the city's total revenue.

Fields:
city_name
highest_revenue_month
revenue
percentage_contribution (%)



SQL QUERY

WITH cte1 AS (SELECT 
        city_id,
        MONTHNAME(start_of_month) AS month_name,
        SUM(fare_amount) AS revenue
    FROM trips_db.fact_trips
    JOIN dim_date USING (date)
    GROUP BY city_id, start_of_month
    ORDER BY city_id),
cte2 AS (SELECT 
        city_id,
        month_name,
        revenue,
        DENSE_RANK() OVER (PARTITION BY city_id ORDER BY revenue DESC) AS rnk
    FROM cte1),
cte3 AS (SELECT 
        city_id,
        SUM(revenue) AS total_revenue
    FROM cte2
    GROUP BY city_id)
SELECT 
    dc.city_name,
    cte2.month_name AS highest_revenue_month,
    cte2.revenue AS highest_revenue,
    ROUND(cte2.revenue / cte3.total_revenue * 100, 2) AS percentage_contri_of_month_in_total
FROM cte2
JOIN cte3 USING (city_id)
JOIN dim_city dc USING (city_id)
WHERE cte2.rnk = 1;



REQUEST 6

Generate a report that calculates two metrics:

Monthly Repeat Passenger Rate: Calculate the repeat passenger rate for each city and month by comparing the number of repeat passengers to the total passengers.
City-wide Repeat Passenger Rate: Calculate the overall repeat passenger rate for each city, considering all passengers across months.

These metrics will provide insights into monthly repeat trends as well as the overall repeat behaviour for each city.
Fields:
city_name
month
total_passengers
repeat_passengers
monthly_repeat_passenger_rate (%): Repeat passenger rate at the city and month level
city_repeat_passenger_rate (%): Overall repeat passenger rate for each city, aggregated across months



SQL QUERY

WITH monthly_repeat_passenger_rates AS (
    SELECT 
        city_id,month,
        SUM(repeat_passengers) AS repeat_passengers,
        SUM(total_passengers) AS total_passengers,
        ROUND(SUM(repeat_passengers) / SUM(total_passengers) * 100, 2) AS monthly_repeat_passenger_rate
    FROM trips_db.fact_passenger_summary
    GROUP BY month , city_id
),
city_repeat_passenger_rates AS (
    SELECT 
        city_id,
        SUM(repeat_passengers) AS repeat_passengers,
        SUM(total_passengers) AS total_passengers,
        ROUND(SUM(repeat_passengers) / SUM(total_passengers) * 100, 2) AS city_repeat_passenger_rate
    FROM trips_db.fact_passenger_summary
    GROUP BY city_id
)
SELECT 
    d.city_name,
    f.month,
    f.total_passengers,
    f.repeat_passengers,
    m.monthly_repeat_passenger_rate,
    c.city_repeat_passenger_rate
FROM trips_db.fact_passenger_summary f
JOIN monthly_repeat_passenger_rates m ON f.month = m.month and  f.city_id=m.city_id
JOIN city_repeat_passenger_rates c ON f.city_id = c.city_id
JOIN dim_city d ON f.city_id = d.city_id
order by city_name and f.month







