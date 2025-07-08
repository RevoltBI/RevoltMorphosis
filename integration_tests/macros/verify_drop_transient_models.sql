{%- macro verify_drop_transient_models() -%}
    {{ log("Verifying transient model cleanup...", info=True) }}

    {% set transient_model_relation = adapter.get_relation(
        database=target.database,
        schema=target.schema,
        identifier='test_transient_model'
    ) %}

    {% set permanent_model_relation = adapter.get_relation(
        database=target.database,
        schema=target.schema,
        identifier='test_permanent_model'
    ) %}

    {% if transient_model_relation is not none %}
        {{ exceptions.raise_compiler_error("Transient model 'test_transient_model' was not dropped.") }}
    {% else %}
        {{ log("OK: Transient model was successfully dropped.", info=True) }}
    {% endif %}

    {% if permanent_model_relation is none %}
        {{ exceptions.raise_compiler_error("Permanent model 'test_permanent_model' was dropped, but it should not have been.") }}
    {% else %}
        {{ log("OK: Permanent model correctly remains.", info=True) }}
    {% endif %}

{%- endmacro -%}
