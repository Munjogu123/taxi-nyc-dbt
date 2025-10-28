{{ config(severity = 'warn') }}

with fact_aggregated as (
    select
        pickup_zone,
        service_type,
        extract(month from pickup_datetime) as month,
        sum(total_amount) as fact_total
    from {{ ref('fact_trips') }}
    group by 1,2,3
),
compare as (
    select
        ts.pickup_zone,
        ts.service_type,
        ts.month,
        ts.monthly_total_amount,
        (ts.monthly_total_amount - fa.fact_total) as difference
    from {{ ref('trips_summary') }} ts
    left join fact_aggregated fa
    on ts.pickup_zone = fa.pickup_zone
    and ts.service_type = fa.service_type
    and ts.month = fa.month
)
select *
from compare
where abs(difference) > 0.01
