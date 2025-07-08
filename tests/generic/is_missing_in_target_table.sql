{% test is_missing_in_target_table(model, column_name, to, field, source_where_condition=none) %}

with source_table as (
    select {{ field }} as from_field
    from {{ to }}
    {%- if source_where_condition is not none %}
    where {{source_where_condition}}
    {%- endif -%}
),

target_table as (
    select {{ column_name }} as to_field
    from {{ model }}
)

select
    from_field

from source_table
left join target_table
    on source_table.from_field = target_table.to_field

where target_table.to_field is null

{% endtest %}