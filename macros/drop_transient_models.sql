{%- macro drop_transient_models(results, transient_tag='RevoltMorphosis_transient') -%}
    {{ log("Dropping transient models tagged with: '" ~ transient_tag ~ "'", info=True) }}
    {% if execute %}
        {% for result in results | selectattr("node.resource_type", "equalto", "model") %}
            {% set node = result.node %}
            {% if transient_tag in node.tags %}
                {% set relation = adapter.get_relation(
                    database=node.database,
                    schema=node.schema,
                    identifier=node.alias
                ) %}
                {% if relation %}
                    {{ log("Dropping relation: " ~ relation, info=True) }}
                    {% do adapter.drop_relation(relation) %}
                {% else %}
                    {{ log("Relation " ~ node.database ~ "." ~ node.schema ~ "." ~ node.alias ~ " not found, skipping.", info=True) }}
                {% endif %}
            {% endif %}
        {% endfor %}
    {% endif %}
{%- endmacro -%}
