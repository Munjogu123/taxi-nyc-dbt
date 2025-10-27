with green_tripdata as (
    select *,
        'Green' as service_type 
    from {{ ref('stg_green_tripdata') }}
),
yellow_tripdata as (
    select *,
        'Yellow' as service_type 
    from {{ ref('stg_yellow_tripdata') }}
),
trips_unioned as (
    select * from green_tripdata
    union all
    select * from yellow_tripdata
),
taxi_zone as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select
    trips_unioned.unique_row_id,
    trips_unioned.vendor_id,
    trips_unioned.service_type,
    trips_unioned.pickup_datetime,
    trips_unioned.dropoff_datetime,
    trips_unioned.store_and_fwd_flag,
    trips_unioned.rate_code_id,
    trips_unioned.pickup_location_id,
    pickup_zone.zone as pickup_zone,
    trips_unioned.dropoff_location_id,
    trips_unioned.passenger_count,
    trips_unioned.trip_distance,
    trips_unioned.fare_amount,
    trips_unioned.extra,
    trips_unioned.mta_tax,
    trips_unioned.tip_amount,
    trips_unioned.tolls_amount,
    trips_unioned.improvement_surcharge,
    trips_unioned.total_amount,
    trips_unioned.payment_type_id,
    trips_unioned.congestion_surcharge,
    trips_unioned.payment_type_description,
    trips_unioned.rate_code_description,
    trips_unioned.vendor_provider
from trips_unioned
inner join taxi_zone as pickup_zone
on trips_unioned.pickup_location_id = pickup_zone.locationid
inner join taxi_zone as dropoff_zone
on trips_unioned.dropoff_location_id = dropoff_zone.locationid
