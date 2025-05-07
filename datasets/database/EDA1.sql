SELECT * FROM dim_city;

select * from dim_date;

select * from dim_repeat_trip_distribution;

select * from fact_passenger_summary;

select * from fact_trips limit 50;

alter table fact_trips
change date dates date;

-- CITY LEVEL FARE & TRIP SUMMARY REPORT
select 
dc.city_name, 
count(*) as total_trips, 
round(avg(ft.fare_amount/ft.distance_travelled_km),0) as avg_fare_per_km,
round(avg(fare_amount),0) as avg_fare_per_trip,
round(count(*) * 100 /(select count(trip_id) from fact_trips),1) as percent_contribution_to_total_trips
from dim_city dc 
join
fact_trips ft using(city_id)
group by 1;

-- MONTHLY CITY LEVEL TRIPS TARGET PERFROMANCE REPORT

with cte1 as (select dc.city_name,dc.city_id, monthname(ft.dates)as month_name, count(trip_id) as actual_trips
from dim_city dc
join
fact_trips ft
using(city_id)
group by 1,2,3),
cte2 as (
select city_id, month, total_target_trips as target_trips from targets_db.monthly_target_trips
)
select 
cte1.city_name, 
cte1.month_name, 
actual_trips, 
target_trips,
(case when actual_trips> target_trips then "Above Target" else "Below Target" end)as performance_status,
round(100*(actual_trips - target_trips)/target_trips,2) as percent_difference
from cte1 
join cte2
on cte1.city_id = cte2.city_id and cte1.month_name = monthname(cte2.month)
order by 1,2; 

-- CITY-LEVEL REPEAT PASSENGER TRIP FREQUENCY REPORT

SELECT dc.city_name, 
(case 
	when trip_count = "2-Trips" then drt.repeat_passenger_count
	else null end) as two_trips
FROM dim_city dc join dim_repeat_trip_distribution drt
using(city_id);

