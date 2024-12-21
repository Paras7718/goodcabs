with monthly_repeat_passenger_rates as
			(SELECT month,sum(repeat_passengers),sum(total_passengers),round(sum(repeat_passengers)/sum(total_passengers)*100,2) as monthly_repeat_passenger_rate
			FROM trips_db.fact_passenger_summary
			group by month)
            
      ,city_repeat_passenger_rates as
			(SELECT city_id,sum(repeat_passengers),sum(total_passengers),round(sum(repeat_passengers)/sum(total_passengers)*100,2) as city_repeat_passenger_rate
			FROM trips_db.fact_passenger_summary
			group by city_id)
            
select d.city_name,f.month,total_passengers,repeat_passengers,monthly_repeat_passenger_rate,city_repeat_passenger_rate
from trips_db.fact_passenger_summary f
join monthly_repeat_passenger_rates m on f.month= m.month
join city_repeat_passenger_rates  c on f.city_id=c.city_id
join dim_city d on  f.city_id=d.city_id