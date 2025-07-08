{% macro snowflake__create_random_data_table(
    table_name,
    target_table_name,
    num_lines,
    generate_randomly
) %}

    {%- set schema=target.schema -%}
    {%- set database=target.database -%}
    {%- set warehouse=target.warehouse -%}

    {%- set generate_randomly_names = generate_randomly.keys() -%}

    {%- set target_table_address=api.Relation.create(database=database, schema=schema, identifier=target_table_name)-%}
    {%- set source_table_address=api.Relation.create(database=database, schema=schema, identifier=table_name) -%}

    {% do run_query('DROP TABLE IF EXISTS ' ~ target_table_address) %}
    {% do run_query('CREATE TABLE ' ~ target_table_address ~ ' LIKE ' ~ source_table_address) %}

    {%- set columns = adapter.get_columns_in_relation(source_table_address) %}

    {%- set insert_query -%}
        INSERT INTO {{target_table_address}}
        (
            {%- for column in columns %}
            "{{column.column}}"
                    {%- if not loop.last -%},{%- endif -%}
            {%- endfor %}
        )
        SELECT
            {% for column in columns -%}
                {%- set column_name_upper = column.column|upper -%}
                {%- if column_name_upper in generate_randomly_names|list -%}
                    {{ generate_randomly[column_name_upper] }}
                {%- else -%}
                    NULL
                {%- endif %} as "{{column.column}}"
                {%- if not loop.last -%},{%- endif -%}
            {% endfor -%}
        FROM TABLE(GENERATOR(ROWCOUNT => {{num_lines}})) a
    {%- endset -%}
    {% do run_query(insert_query) %}

    {%- set columns_to_update = [] -%}
    {%- for column in columns -%}
        {%- if column.column|upper not in generate_randomly_names|list -%}
            {% do columns_to_update.append(column) %}
        {%- endif %}
    {%- endfor %}

    {% if columns_to_update %}
        {% for column in columns_to_update %}
            {%- set update_query -%}
                UPDATE {{target_table_address}} SET "{{column.column}}" =
                GET (arr, FLOOR(ARRAY_SIZE(arr)*(uniform(1,10000,random())/10000) ))
                FROM
                    (
                    SELECT ARRAY_AGG("{{column.column}}") WITHIN GROUP (ORDER BY "{{column.column}}" ASC) arr
                    FROM
                        (SELECT
                        "{{column.column}}"
                        FROM {{source_table_address}}
                        WHERE "{{column.column}}" is not null {% if column.dtype == 'VARCHAR' %} AND "{{column.column}}" != ''{% endif %}
                        limit {{num_lines}}
                        ) source
                    ) transposed
            {%- endset -%}
            {% do run_query(update_query) %}
        {% endfor %}
    {% endif %}

{% endmacro %}