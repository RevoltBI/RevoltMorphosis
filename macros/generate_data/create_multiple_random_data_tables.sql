{% macro create_multiple_random_data_tables(
    dimension_tables=[],
    fact_tables=[],
    number_of_lines_dimension=100,
    number_of_lines_fact=1000,
    prefix="DEMO_",
    generate_randomly={}
) %}
    {% for table in dimension_tables %}
        {{ RevoltMorphosis.create_random_data_table(
            table_name=table,
            target_table_name=prefix ~ table,
            num_lines=number_of_lines_dimension,
            generate_randomly=generate_randomly
        ) }}
    {% endfor %}

    {% for table in fact_tables %}
        {{ RevoltMorphosis.create_random_data_table(
            table_name=table,
            target_table_name=prefix ~ table,
            num_lines=number_of_lines_fact,
            generate_randomly=generate_randomly
        ) }}
    {% endfor %}

{% endmacro %}