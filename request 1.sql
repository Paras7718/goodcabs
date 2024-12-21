with cte1 as (SELECT city_id, count(trip_id)  as  total_trips ,sum(fare_amount) as  total_fare ,sum(distance_travelled_km) as total_dis_travel_km
 FROM trips_db.fact_trips
 group by city_id)

select city_name,city_id,total_trips, 
		round(total_fare/total_dis_travel_km,2) as avg_fare_per_km ,
        round(total_fare/total_trips,2) as  avg_fare_per_trip,
        round(total_trips/( select count(trip_id) as total_trips_count from  fact_trips ) *100,2) as per_contribution_to_total_trips
	from cte1 
    join dim_city
    using (city_id)
   
        