The `run_query` macro provides a convenient way to run queries and fetch their results. It is a wrapper around the statement block, which is more flexible, but also more complicated to use.

**Args**:

*   `query`: The SQL query to execute

Returns a Table object with the result of the query. If the specified query does not return results (eg. a DDL, DML, or maintenance query), then the return value will be `none`.

**Note:** The `run_query` macro will not begin a transaction automatically - if you wish to run your query inside of a transaction, please use `begin` and `commit ` statements as appropriate.

**Example Usage:**

**models/my_model.sql**
```sql
{% set results = run_query('select 1 as id') %}
{% do results.print_table() %}
-- do something with `results` here...
```

**macros/run_grants.sql**
```sql
{% macro run_vacuum(table) %}
  {% set query %}
    vacuum table {{ table }}
  {% endset %}
  {% do run_query(query) %}
{% endmacro %}
```

Here's an example of using this (though if you're using `run_query` to return the values of a column, check out the get_column_values macro in the dbt-utils package).

**models/my_model.sql**
```sql
{% set payment_methods_query %}
select distinct payment_method from app_data.payments
order by 1
{% endset %}

{% set results = run_query(payment_methods_query) %}

{% if execute %}
{# Return the first column #}
{% set results_list = results.columns[0].values() %}
{% else %}
{% set results_list = [] %}
{% endif %}

select
  order_id,
  {% for payment_method in results_list %}
  sum(case when payment_method = '{{ payment_method }}' then amount end) as {{ payment_method }}_amount,
  {% endfor %}
  sum(amount) as total_amount
from {{ ref('raw_payments') }}
group by 1
```

You can also use `run_query` to perform SQL queries that aren't select statements.

**macros/run_vacuum.sql**
```sql
{% macro run_vacuum(table) %}
  {% set query %}
    vacuum table {{ table }}
  {% endset %}
  {% do run_query(query) %}
{% endmacro %}
```

Use the `length` filter to verify whether `run_query` returned any rows or not. Make sure to wrap the logic in an if execute block to avoid unexpected behavior during parsing.

```sql
{% if execute %}
  {% set results = run_query(payment_methods_query) %}
  {% if results|length > 0 %}
  	-- do something with `results` here...
  {% else %}
    -- do fallback here...
  {% endif %}
{% endif %}
