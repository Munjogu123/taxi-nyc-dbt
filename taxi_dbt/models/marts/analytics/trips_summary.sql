with fact_trips as (
    select * from {{ ref('fact_trips') }}
)
select
    pickup_zone,
    service_type,
    extract(month from pickup_datetime) as month,
    sum(fare_amount) as monthly_fare_amount,
    sum(extra) as monthly_extra,
    sum(mta_tax) as monthly_mta_tax,
    sum(tip_amount) as monthly_tips_amount,
    sum(tolls_amount) as monthly_tolls_amount,
    sum(total_amount) as monthly_total_amount,
    count(unique_row_id) as total_monthly_trips,
    avg(passenger_count) as avg_monthly_passengers,
    avg(trip_distance) as avg_monthly_trip_distance
from fact_trips
group by 1,2,3
