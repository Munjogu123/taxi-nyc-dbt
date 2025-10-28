{{ config(severity = 'warn') }}

with payment_summary as (
    select
        total_trips,
        total_revenue
    from {{ ref('payment_summary') }}
)
select *
from payment_summary
where total_trips > 0 
and total_revenue <= 0
