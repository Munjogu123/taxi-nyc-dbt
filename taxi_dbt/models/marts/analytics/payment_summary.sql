with fact_trips as (
    select * from {{ ref('fact_trips') }}
)
select
    payment_type_description as payment_description,
    count(unique_row_id) as total_trips,
    avg(total_amount) as avg_total_amount,
    avg(tip_amount) as avg_tip,
    sum(total_amount) as total_revenue
from fact_trips
group by 1
order by total_revenue desc
