{#
    This is a macro that defines the payment type based on the id
#}

{% macro get_payment_type(payment_type_id) %}

    case {{ payment_type_id }}
        when 0 then 'Flex Fare trip'
        when 1 then 'Credit Card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end

{% endmacro %}
