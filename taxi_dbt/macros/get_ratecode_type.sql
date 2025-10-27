{#
    This defines the final rate code in effect at the end of the trip based on its ID
#}

{% macro get_ratecode_type(ratecodeid) %}

    case {{ ratecodeid }}
        when 1 then 'Standard rate'
        when 2 then 'JFK'
        when 3 then 'Newark'
        when 4 then 'Nassau or Westchester'
        when 5 then 'Negotiated fare'
        when 6 then 'Group ride'
        else 'Unknown'
    end

{% endmacro %}
