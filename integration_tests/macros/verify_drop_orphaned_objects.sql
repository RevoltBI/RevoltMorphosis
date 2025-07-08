{% macro verify_drop_orphaned_objects() %}
    {% set mock_table_exists = adapter.get_relation(database=target.database, schema=target.schema, identifier='MOCK_test_table') is not none %}

    {% if mock_table_exists %}
        {{ exceptions.raise_compiler_error("Mock table was not dropped.") }}
    {% else %}
        {{ log("Mock table was successfully dropped.", info=True) }}
    {% endif %}
{% endmacro %}
