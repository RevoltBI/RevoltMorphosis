{% macro standardize_model(relation,
                           exclude_columns=['_timestamp'],
                           columns_mode='upper',
                           empty_to_null=false,
                           surrogate_key_columns=[],
                           surrogate_key_delimiter='-',
                           hash_surrogate_key=false) %}

{#- Check to see if user select combination is valid. -#}
{%- if hash_surrogate_key and surrogate_key_columns == [] -%}
    {{ exceptions.raise_compiler_error('Error type: There are no surrogate key columns to be hashed.') }}
{%- endif -%}

{#- Create a lower case version of the exclude_columns and surrogate_key_columns for easier comparison -#}
{#- This is used to ensure that the column names are compared in a case-insensitive manner -#}
{%- set exclude_columns_lower = [] -%}
{% for column in exclude_columns %}
    {%- do exclude_columns_lower.append(column.lower()) -%}
{% endfor %}

{%- set surrogate_key_columns_lower = [] -%}
{% for column in surrogate_key_columns %}
    {%- do surrogate_key_columns_lower.append(column.lower()) -%}
{% endfor %}


{%- set array_columns = [] -%}
{%- set modified_surrogate_key_columns = [] -%}
{%- for column in adapter.get_columns_in_relation(relation) %}
    {%- if column.column.lower() not in exclude_columns_lower -%}
        {%- do array_columns.append(column) -%}
    {%- endif -%}
    {%- if column.column.lower() in surrogate_key_columns_lower -%}
        {%- do modified_surrogate_key_columns.append(adapter.quote(column.column)) -%}
    {%- endif -%}
{%- endfor -%}

SELECT
    {% if hash_surrogate_key %}
    {#- generate hashed surrogate key of set columns -#}
        {{ dbt_utils.generate_surrogate_key(modified_surrogate_key_columns) }} as {{ RevoltMorphosis.__convert_string('surrogate_key', columns_mode) }},
    {%- elif surrogate_key_columns != [] -%}
        CONCAT(
        {%- for column in modified_surrogate_key_columns -%}
            IFNULL(CAST({{column}} AS {{ dbt.type_string() }}), '')
            {%- if not loop.last %},'{{surrogate_key_delimiter}}',{% endif %}
        {%- endfor -%}
        ) as {{ RevoltMorphosis.__convert_string('surrogate_key', columns_mode) }},
    {%- endif %}
    {%- for column in array_columns %}
        {%- if column.is_string() and empty_to_null == true %}
    NULLIF({{column.column}}, '')
        {%- else %}
    {{column.column}}
        {%- endif -%} 
        {{ ' as ' ~ RevoltMorphosis.__convert_string(column.column, columns_mode)}}
        {%- if not loop.last %},{% endif %}
    {%- endfor %}
FROM {{ relation }}
{% endmacro %}