with total_repeat_pass as(SELECT city_id, sum(repeat_passenger_count) as total_repeat_pass 
							FROM trips_db.dim_repeat_trip_distribution group by city_id)

select city_id,sum(case when trip_count ="2-trips" then round(repeat_passenger_count/total_repeat_pass *100,2) else 0 end ) as 2_trips ,
				sum(case when trip_count ="3-trips" then round(repeat_passenger_count/total_repeat_pass *100,2)  else 0  end) as 3_trips ,
                sum(case when trip_count ="4-trips" then round(repeat_passenger_count/total_repeat_pass *100,2)   else 0  end) as 4_trips ,
                sum(case when trip_count ="5-trips" then round(repeat_passenger_count/total_repeat_pass *100 ,2) else 0  end) as 5_trips ,
                sum(case when trip_count ="6-trips" then round(repeat_passenger_count/total_repeat_pass *100,2) else 0  end) as 6_trips ,
                sum(case when trip_count ="7-trips" then round(repeat_passenger_count/total_repeat_pass *100,2)  else 0  end) as 7_trips ,
                sum(case when trip_count ="8-trips" then round(repeat_passenger_count/total_repeat_pass *100,2)  else 0  end) as 8_trips ,
                sum(case when trip_count ="9-trips" then round(repeat_passenger_count/total_repeat_pass *100,2)  else 0  end) as 9_trips ,
                sum(case when trip_count ="10-trips" then round(repeat_passenger_count/total_repeat_pass *100,2)   else 0  end) as 10_trips 
from dim_repeat_trip_distribution
join total_repeat_pass
using (city_id)
group by city_id
