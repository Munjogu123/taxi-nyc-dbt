{#
  This macro creates a schema if it does not exist based on the schema name defined
#}

{% macro create_schema_if_not_exists(schema_name=target.schema) %}

  {% set sql %}  
    create_schema_if_not_exists {{ schema_name }}
  {% endset %}

{% endmacro %}
