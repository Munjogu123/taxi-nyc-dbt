{{ config(severity = 'error') }}


with fact_trips as (
    select
        fare_amount,
        total_amount
    from {{ ref('fact_trips') }}
),
validate_amount as (
    select *
    from fact_trips
    where total_amount < fare_amount
)
select * from validate_amount
