# dbt Cross-Database Type Checking

When writing dbt macros that need to perform different logic based on a column's data type, it is crucial to use dbt's built-in, abstract methods for type checking to ensure cross-database compatibility.

## The Problem

Relying on the `column.dtype` property directly is unreliable because the string value it returns is specific to the database adapter being used.

For example:
- On Snowflake, a string column might have a `dtype` of `'VARCHAR'`.
- On BigQuery, the same column would have a `dtype` of `'STRING'`.

Hardcoding checks like `if column.dtype == 'VARCHAR'` will cause the logic to fail on other platforms.

## The Solution

Always use the `Column` object's built-in type-checking methods, which abstract away the adapter-specific differences. The most common method for this is `column.is_string()`.

**Correct (Cross-Database Compatible):**
```jinja
{%- if column.is_string() and empty_to_null == true %}
    NULLIF({{column.column}}, '')
{%- else %}
    {{column.column}}
{%- endif -%}
```

**Incorrect (Not Cross-Database Compatible):**
```jinja
{%- if (column.dtype == 'VARCHAR' or column.dtype == 'STRING') and empty_to_null == true %}
    NULLIF({{column.column}}, '')
{%- else %}
    {{column.column}}
{%- endif -%}
```

Using the provided methods (`is_string()`, `is_numeric()`, `is_float()`, etc.) makes your macros more robust, maintainable, and truly portable across different data warehouses.