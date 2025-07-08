{% macro bigquery__create_random_data_table(
    table_name,
    target_table_name,
    num_lines,
    generate_randomly
) %}

    {%- set dataset=target.dataset -%}
    {%- set project=target.project -%}

    {%- set generate_randomly_names = generate_randomly.keys() -%}

    {%- set target_table_address=api.Relation.create(database=project, schema=dataset, identifier=target_table_name)-%}
    {%- set source_table_address=api.Relation.create(database=project, schema=dataset, identifier=table_name) -%}

    {% do run_query('DROP TABLE IF EXISTS ' ~ target_table_address) %}
    {% do run_query('CREATE TABLE ' ~ target_table_address ~ ' LIKE ' ~ source_table_address) %}

    {%- set columns = adapter.get_columns_in_relation(source_table_address) %}

    {%- set insert_query -%}
        INSERT INTO {{target_table_address}}
        (
            {%- for column in columns %}
            {{column.column}}
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
                {%- endif %} as {{column.column}}
                {%- if not loop.last -%},{%- endif -%}
            {% endfor %}
        FROM UNNEST(GENERATE_ARRAY(1, {{num_lines}})) AS ID
    {%- endset -%}
    {% do run_query(insert_query) %}

    {%- set columns_to_update = [] -%}
    {%- for column in columns -%}
        {%- if column.column|upper not in generate_randomly_names|list -%}
            {% do columns_to_update.append(column) %}
        {%- endif %}
    {%- endfor %}

    {% if columns_to_update %}
        {%- set update_query -%}
        BEGIN
            ALTER TABLE {{ target_table_address }} ADD COLUMN IF NOT EXISTS temp_update_id STRING;
            UPDATE {{ target_table_address }} SET temp_update_id = GENERATE_UUID() WHERE temp_update_id IS NULL;

            {% for column in columns_to_update %}
            CREATE OR REPLACE TEMP TABLE distinct_shuffled_{{column.column}} AS
            SELECT
                {{column.column}},
                ROW_NUMBER() OVER() as rn,
                COUNT(*) OVER() as total_count
            FROM (
                SELECT {{column.column}}
                FROM {{source_table_address}}
                WHERE {{column.column}} IS NOT NULL {% if column.dtype == 'STRING' %} AND {{column.column}} != ''{% endif %}
                ORDER BY RAND()
            );
            {% endfor %}

            CREATE OR REPLACE TEMP TABLE temp_update_table AS
            SELECT
                S.temp_update_id
                {% for column in columns_to_update -%}
                ,T_{{column.column}}.{{column.column}} as new_{{column.column}}
                {% endfor %}
            FROM {{ target_table_address }} S
            {% for column in columns_to_update %}
            LEFT JOIN distinct_shuffled_{{column.column}} T_{{column.column}}
                ON MOD(ABS(FARM_FINGERPRINT(S.temp_update_id || '{{column.column}}')), T_{{column.column}}.total_count) + 1 = T_{{column.column}}.rn
            {% endfor %};

            {% for column in columns_to_update %}
            DROP TABLE IF EXISTS distinct_shuffled_{{column.column}};
            {% endfor %}

            UPDATE {{ target_table_address }} T
            SET
            {% for column in columns_to_update -%}
                T.{{ column.column }} = S.new_{{ column.column }}{% if not loop.last %},{% endif %}
            {%- endfor %}
            FROM temp_update_table S
            WHERE T.temp_update_id = S.temp_update_id;

            DROP TABLE IF EXISTS temp_update_table;

            ALTER TABLE {{ target_table_address }} DROP COLUMN temp_update_id;
        END;
        {%- endset -%}
        {% do run_query(update_query) %}

        {%- set shuffle_query -%}
        CREATE OR REPLACE TABLE {{ target_table_address }} AS
        SELECT *
        FROM {{ target_table_address }}
        ORDER BY RAND();
        {%- endset -%}
        {% do run_query(shuffle_query) %}
    {% endif %}

{% endmacro %}