{% test is_positive(model, column_name) %}

{{ config(severity = 'warn') }}

with validation as (
    select
        unique_row_id, 
        {{ column_name }} as positive_field
    from {{ model }}
),
validation_errors as (
    select *
    from validation
    where positive_field < 0
)
select *
from validation_errors

{% endtest %}
