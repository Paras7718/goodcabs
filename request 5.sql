with cte1 as (SELECT city_id,monthname(start_of_month) as   month_name ,sum(fare_amount) as revenue
 FROM trips_db.fact_trips
 join dim_date using (date)
 group by city_id,start_of_month
 order by city_id)
 
 ,cte2 as(select city_id,month_name,revenue ,dense_rank() over(partition by city_id order by revenue desc) as rnk
 from cte1)
 
 ,cte3 as( select city_id,sum(revenue)as total_revenue from cte2 group by city_id)
 
 select city_name,month_name as highest_revenue_month,cte2.revenue as highest_revenue,round( revenue/total_revenue*100,2) as percentage_contri_of_month_in_total
 from cte2 
 join cte3 using (city_id)
 join dim_city using(city_id) 
 where rnk =1
