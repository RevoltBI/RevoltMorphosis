{% macro anonymize_data(relation, anonymized_columns, create_new_column=True, original_value_suffix='_ORIGINAL') %}
    {%- if execute -%}
        {% set columns = adapter.get_columns_in_relation(relation) %}

        {%- set anonymized_columns_lower = [] -%}
        {%- for col in anonymized_columns -%}
            {%- do anonymized_columns_lower.append(col|lower) -%}
        {%- endfor -%}

        {% set sql_query %}
        SELECT
            {% for column in columns -%}
                {%- if column.name|lower in anonymized_columns_lower -%}
                    CASE
                        WHEN {{ adapter.quote(column.name) }} IS NULL THEN NULL
                        ELSE {{ dbt.hash(adapter.quote(column.name)) }}
                    END AS {{ adapter.quote(column.name) }}
                    {%- if create_new_column -%}
                        , {{ adapter.quote(column.name) }} AS {{ adapter.quote(column.name ~ original_value_suffix) }}
                    {%- endif -%}
                {%- else -%}
                    {{ adapter.quote(column.name) }}
                {%- endif -%}
                {%- if not loop.last %} ,{% endif %}
            {%- endfor -%}
        FROM {{ relation }}
        {% endset %}
        {{ sql_query }}
    {%- endif -%}
{% endmacro %}