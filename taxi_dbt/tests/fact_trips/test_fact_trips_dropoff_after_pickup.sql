{{ config(severity = 'warn') }}

with fact_trips as (
    select 
        pickup_datetime,
        dropoff_datetime
    from {{ ref('fact_trips') }}
),
validate_trip as (
    select *
    from fact_trips
    where dropoff_datetime < pickup_datetime
)
select * from validate_trip
