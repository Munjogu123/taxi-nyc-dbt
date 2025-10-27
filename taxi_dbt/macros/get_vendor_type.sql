{#
    This macro defines the vendor type depending on the id
#}

{% macro get_vendor_type(vendor_id) %}
  
    case {{ vendor_id }}
      when 1 then 'Creative Mobile Technologies, LLC'
      when 2 then 'Curb Mobility, LLC.'
      when 6 then 'Myle Technologies Inc'
      when 7 then 'Helix'
      else 'Unknown'
    end

{% endmacro %}
