{% macro create_random_data_table(
    table_name,
    target_table_name,
    num_lines=100,
    generate_randomly={}
) %}
    {% set upper_generate_randomly = {} %}
    {% for key, value in generate_randomly.items() %}
        {% do upper_generate_randomly.update({key|upper: value}) %}
    {% endfor %}
    {{ adapter.dispatch('create_random_data_table', 'RevoltMorphosis')(
        table_name=table_name,
        target_table_name=target_table_name,
        num_lines=num_lines,
        generate_randomly=upper_generate_randomly
    ) }}
{% endmacro %}

{% macro default__create_random_data_table(
    table_name,
    target_table_name,
    num_lines,
    generate_randomly
) %}
    {{ exceptions.raise_compiler_error("The create_random_data_table macro is not supported on this adapter.") }}
{% endmacro %}