{%- macro drop_orphaned_objects(objects_type=['BASE TABLE', 'VIEW'], dry_run=true, tables_to_exclude=[''], delete_custom_schemas=false, schemas_to_exclude=['']) -%}
    {% if execute %}
        {%- set schemas_to_exclude_lower = [] -%}
        {%- for s in schemas_to_exclude -%}
            {%- do schemas_to_exclude_lower.append(s.lower()) -%}
        {%- endfor -%}
        {%- set schemas_to_exclude_lower = schemas_to_exclude_lower + ['information_schema'] -%}

        {#- Get all schemas that are defined in the dbt project -#}
        {% set dbt_project_schemas = [] %}
        {% set dbt_project_schemas_lower = [] %}
        {% for node in graph.nodes.values() | selectattr("resource_type", "in", ["model", "seed", "snapshot"]) %}
            {% if node.schema.lower() not in dbt_project_schemas_lower %}
                {% do dbt_project_schemas.append(node.schema) %}
                {% do dbt_project_schemas_lower.append(node.schema.lower()) %}
            {% endif %}
        {% endfor %}

        {#- Get all existing relations in the database for the project schemas -#}
        {%- set objects_type_str -%}
            ({%- for object_type in objects_type -%}
                '{{ object_type|upper }}'
                {%- if not loop.last %},{%- endif -%}
            {%- endfor -%})
        {%- endset -%}

        {%- set select_clause -%}
            select
                case
                    when table_type in ('BASE TABLE', 'MANAGED') then 'TABLE'
                    when table_type = 'VIEW' then 'VIEW'
                    else table_type
                end as RELATION_TYPE,
                table_catalog || '.' || table_schema || '.' || table_name as RELATION_NAME,
                table_schema as TABLE_SCHEMA,
                table_name as TABLE_NAME
        {%- endset -%}

        {%- set relations_query -%}
            {% if target.type == 'bigquery' %}
                {% for schema in dbt_project_schemas %}
                    {{ select_clause }}
                    from `{{ target.database }}.{{ schema }}.INFORMATION_SCHEMA.TABLES`
                    where table_type in {{ objects_type_str }}
                    {% if not loop.last %} union all {% endif %}
                {% endfor %}
            {% else %}
                {{ select_clause }}
                from {{ target.database }}.information_schema.tables
                where table_type in {{ objects_type_str }}
                and lower(table_schema) in ('{{ dbt_project_schemas_lower | join("', '") }}')
            {% endif %}
        {%- endset -%}
        
        {% set existing_relations = run_query(relations_query) %}

        {#- Get all relations that are defined in the dbt project -#}
        {% set dbt_relations = [] %}
        {% for node in graph.nodes.values() | selectattr("resource_type", "in", ["model", "seed", "snapshot"]) %}
            {% set relation_name = (node.database ~ '.' ~ node.schema ~ '.' ~ node.name) %}
            {% do dbt_relations.append(relation_name.upper()) %}
        {% endfor %}

        {#- Find relations that exist in the database but not in the dbt project -#}
        {% set orphaned_relations = [] %}
        {% for row in existing_relations %}
            {% set relation_name = row['RELATION_NAME'] %}
            {% if relation_name.upper() not in dbt_relations and row['TABLE_SCHEMA'].lower() not in schemas_to_exclude_lower and row['TABLE_NAME'].lower() not in tables_to_exclude %}
                {% do orphaned_relations.append(row) %}
            {% endif %}
        {% endfor %}

        {% if orphaned_relations | length > 0 %}
            {{ log("Orphaned relations to be dropped:", info=True) }}
            {% for row in orphaned_relations %}
                {% set drop_command = "DROP " ~ row['RELATION_TYPE'] ~ " IF EXISTS " ~ row['RELATION_NAME'] ~ ";" %}
                {% if not dry_run %}
                    {{ log("Executing: " ~ drop_command, info=True) }}
                    {% do run_query(drop_command) %}
                {% else %}
                    {{ log(drop_command, info=True) }}
                {% endif %}
            {% endfor %}
        {% else %}
            {{ log("No orphaned relations found.", info=True) }}
        {% endif %}

        {% if delete_custom_schemas %}
            {#- Get all existing schemas in the database -#}
            {%- set information_schema_schemata -%}
                {% if target.type == 'bigquery' %}
                    `{{ target.database }}.INFORMATION_SCHEMA.SCHEMATA`
                {% else %}
                    {{ target.database }}.information_schema.schemata
                {% endif %}
            {%- endset -%}
            {%- set schemas_query -%}
                select schema_name as SCHEMA_NAME
                from {{ information_schema_schemata }}
            {%- endset -%}
            {% set existing_schemas = run_query(schemas_query) %}

            {#- Find schemas that exist in the database but not in the dbt project -#}
            {% set orphaned_schemas = [] %}
            {% for row in existing_schemas %}
                {% set schema_name = row['SCHEMA_NAME'] %}
                {% if schema_name.lower() not in dbt_project_schemas_lower and schema_name.lower() not in schemas_to_exclude_lower %}
                    {% do orphaned_schemas.append(schema_name) %}
                {% endif %}
            {% endfor %}

            {% if orphaned_schemas | length > 0 %}
                {{ log("Orphaned schemas to be dropped:", info=True) }}
                {% for schema_name in orphaned_schemas %}
                    {% set drop_command = "DROP SCHEMA IF EXISTS " ~ target.database ~ "." ~ schema_name ~ " CASCADE;" %}
                    {% if not dry_run %}
                        {{ log("Executing: " ~ drop_command, info=True) }}
                        {% do run_query(drop_command) %}
                    {% else %}
                        {{ log(drop_command, info=True) }}
                    {% endif %}
                {% endfor %}
            {% else %}
                {{ log("No orphaned schemas found.", info=True) }}
            {% endif %}
        {% endif %}
    {% endif %}
{%- endmacro -%}