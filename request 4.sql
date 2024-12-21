with cte1 as (SELECT city_id,sum(new_passengers) as new_passengers,dense_rank() over (order by  sum(new_passengers) desc) as rnk	
				 FROM trips_db.fact_passenger_summary
				 group by city_id)

 select  city_name ,  new_passengers, case when rnk = 1  then "Top 3" 
										 when rnk = 2 then "Top 3" 
										 when rnk = 3  then "Top 3" 
										 when rnk = 8  then "Bottom 3" 
										 when rnk = 9  then "Bottom 3" 
										 when rnk = 10  then "Bottom 3" 
										 else "" end as city_category
 from cte1
 join dim_city
 using (city_id)
 where rnk in (1,2,3,8,9,10)
 