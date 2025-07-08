{% macro inspect_relation(relation_name, limit=10, output_csv=false) %}
    {% set relation = adapter.Relation.create(database=target.database, schema=target.schema, identifier=relation_name) %}

    {% set query %}
        SELECT * FROM {{ relation }} LIMIT {{ limit }}
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute %}
        {% if not output_csv %}
            {%- set columns = adapter.get_columns_in_relation(relation) -%}
            {{ log('--- Schema for ' ~ relation ~ ' ---', info=True) }}
            {%- for column in columns -%}
                {{ log(column.name ~ ' (' ~ column.dtype ~ ')', info=True) }}
            {%- endfor -%}
            {{ log('--- End Schema ---', info=True) }}

            {% set column_names = results.column_names %}
            {{ log('--- Data for ' ~ relation ~ ' (first ' ~ limit ~ ' rows) ---', info=True) }}
            {{ log(column_names | join(', '), info=True) }}
            {{ log('---', info=True) }}
            {% for row in results %}
                {{ log(row.values() | join(', '), info=True) }}
            {% endfor %}
            {{ log('--- End Data ---', info=True) }}
        {% else %}
            {% set csv_output = [] %}
            {% set quoted_header = [] %}
            {% for col in results.column_names %}
                {% do quoted_header.append('"' ~ col | replace('"', '""') ~ '"') %}
            {% endfor %}
            {% do csv_output.append(quoted_header | join(',')) %}
            {% for row in results %}
                {% set quoted_row = [] %}
                {% for value in row.values() %}
                    {% if value is none %}
                        {% do quoted_row.append('') %}
                    {% else %}
                        {% do quoted_row.append('"' ~ value | string | replace('"', '""') ~ '"') %}
                    {% endif %}
                {% endfor %}
                {% do csv_output.append(quoted_row | join(',')) %}
            {% endfor %}
            {% do print(csv_output | join('\n')) %}
        {% endif %}
    {% endif %}
{% endmacro %}