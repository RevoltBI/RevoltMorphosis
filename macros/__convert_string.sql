{% macro __convert_string(string, mode) %}
{%- if mode == 'upper' -%}
    {{ adapter.quote(string.upper()) }}
{%- elif mode == 'lower' -%}
    {{ adapter.quote(string.lower()) }}
{%- elif mode == 'title' -%}
    {{ adapter.quote(string.title()) }}
{%- elif mode == 'capitalize' -%}
    {{ adapter.quote(string.capitalize()) }}
{%- elif mode == 'keep' -%}
    {{ adapter.quote(string) }}
{%- else -%}
    {{ exceptions.raise_compiler_error("Error type: Invalid mode specified. Use 'upper', 'lower', 'title', 'capitalize' or 'keep'.") }}
{%- endif %}
{% endmacro %}