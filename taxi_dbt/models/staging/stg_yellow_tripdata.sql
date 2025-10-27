with source as (
    select * from {{ source('staging', 'yellow_tripdata') }}
    where vendorid != ''
)
select
    unique_row_id,
    cast(vendorid as integer) as vendor_id,
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
    store_and_fwd_flag,
    cast(ratecodeid as integer) as rate_code_id,
    cast(pulocationid as integer) as pickup_location_id,
    cast(dolocationid as integer) as dropoff_location_id,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric(10,2)) as trip_distance,
    cast(fare_amount as numeric(10,2)) as fare_amount,
    cast(extra as numeric(10,2)) as extra,
    cast(mta_tax as numeric(10,2)) as mta_tax,
    cast(tip_amount as numeric(10,2)) as tip_amount,
    cast(tolls_amount as numeric(10,2)) as tolls_amount,
    cast(improvement_surcharge as numeric(10,2)) as improvement_surcharge,
    cast(total_amount as numeric(10,2)) as total_amount,
    cast(payment_type as integer) as payment_type_id,
    cast(congestion_surcharge as numeric(10,2)) as congestion_surcharge,
    {{ get_payment_type('payment_type_id') }} as payment_type_description,
    {{ get_ratecode_type('rate_code_id') }} as rate_code_description,
    {{ get_vendor_type('vendor_id') }} as vendor_provider 
from source


{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
