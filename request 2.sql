with actuals as(SELECT f.city_id ,start_of_month,count(trip_id) as actual_trips
				FROM trips_db.fact_trips f
				join dim_date d
				using(date)
				group by city_id,start_of_month)
                
	,target as(SELECT distinct(city_id) ,start_of_month,total_target_trips as target_trips
				FROM targets_db. monthly_target_trips t
                join dim_date	d
                on d.start_of_month=t.month)
			
select city_name,monthname(start_of_month),actual_trips,target_trips,
		if(target_trips>actual_trips,"Below Target","Above_Target") as performance_status,
		round((actual_trips-target_trips)/target_trips *100 ,2)  as percentage_difference
from actuals
join target using (city_id,start_of_month)
join dim_city using(city_id)
order by start_of_month,city_name
