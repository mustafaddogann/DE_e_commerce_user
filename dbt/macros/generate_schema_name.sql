-- Use the +schema config verbatim instead of concatenating with target.schema.
-- This gives us clean `silver` / `gold` instead of `silver_silver` / `silver_gold`.
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
