dbt has a number of classes it uses to represent objects in a data warehouse, parts of a dbt project, and the results of a command.

These classes are often useful when building advanced dbt models and macros.

# Relation

The `Relation` object is used to interpolate schema and table names into SQL code with appropriate quoting. This object should _always_ be used instead of interpolating values with `{{ schema }}.{{ table }}` directly. Quoting of the Relation object can be configured using the `quoting` config.

### Creating relations

A `Relation` can be created by calling the `create` class method on the `Relation` class.

**Relation.create**
```python
class Relation:
  def create(database=None, schema=None, identifier=None, type=None):
    """
    database (optional): The name of the database for this relation
    schema (optional): The name of the schema (or dataset, if on BigQuery) for this relation
    identifier (optional): The name of the identifier for this relation
    type (optional): Metadata about this relation, eg: "table", "view", "cte"
    """
```

### Using relations

In addition to `api.Relation.create`, dbt returns a Relation when you use `ref`, `source` or `this`.

**relation_usage.sql**
```sql
{% set relation = api.Relation.create(schema='snowplow', identifier='events') %}
-- Return the `database` for this relation
{{ relation.database }}
-- Return the `schema` (or dataset) for this relation
{{ relation.schema }}
-- Return the `identifier` for this relation
{{ relation.identifier }}
-- Return relation name without the database
{{ relation.include(database=false) }}
-- Return true if the relation is a table
{{ relation.is_table }}
-- Return true if the relation is a view
{{ relation.is_view }}
-- Return true if the relation is a cte
{{ relation.is_cte }}
```

# Column

The `Column` object is used to encode information about a column in a relation.

**column.py**
```python
class Column(object):
  def __init__(self, column, dtype, char_size=None, numeric_size=None):
    """
    column: The name of the column represented by this object
    dtype: The data type of the column (database-specific)
    char_size: If dtype is a variable width character type, the size of the column, or else None
    numeric_size: If dtype is a fixed precision numeric type, the size of the column, or else None
    """

# Example usage:
col = Column('name', 'varchar', 255)
col.is_string() # True
col.is_numeric() # False
col.is_number() # False
col.is_integer() # False
col.is_float() # False
col.string_type() # character varying(255)
col.numeric_type('numeric', 12, 4) # numeric(12,4)
```

### Column API

#### Properties
*   **char_size**: Returns the maximum size for character varying columns
*   **column**: Returns the name of the column
*   **data_type**: Returns the data type of the column (with size/precision/scale included)
*   **dtype**: Returns the data type of the column (without any size/precision/scale included)
*   **name**: Returns the name of the column (identical to `column`, provided as an alias).
*   **numeric_precision**: Returns the maximum precision for fixed decimal columns
*   **numeric_scale**: Returns the maximum scale for fixed decimal columns
*   **quoted**: Returns the name of the column wrapped in quotes

#### Instance methods
*   **is_string()**: Returns True if the column is a String type (eg. text, varchar), else False
*   **is_numeric()**: Returns True if the column is a fixed-precision Numeric type (eg. `numeric`), else False
*   **is_number()**: Returns True if the column is a number-y type (eg. `numeric`, `int`, `float`, or similar), else False
*   **is_integer()**: Returns True if the column is an integer (eg. `int`, `bigint`, `serial` or similar), else False
*   **is_float()**: Returns True if the column is a float type (eg. `float`, `float64`, or similar), else False
*   **string_size()**: Returns the width of the column if it is a string type, else, an exception is raised

#### Static methods
*   **string_type(size)**: Returns a database-useable representation of the string type (eg. `character varying(255)`)
*   **numeric_type(dtype, precision, scale)**: Returns a database-useable representation of the numeric type (eg. `numeric(12, 4)`)

### Using columns

**column_usage.sql**
```sql
-- String column
{%- set string_column = api.Column('name', 'varchar', char_size=255) %}
-- Return true if the column is a string
{{ string_column.is_string() }}
-- Return true if the column is a numeric
{{ string_column.is_numeric() }}
-- Return true if the column is a number
{{ string_column.is_number() }}
-- Return true if the column is an integer
{{ string_column.is_integer() }}
-- Return true if the column is a float
{{ string_column.is_float() }}

-- Numeric column
{%- set numeric_column = api.Column('distance_traveled', 'numeric', numeric_precision=12, numeric_scale=4) %}
-- Return true if the column is a string
{{ numeric_column.is_string() }}
-- Return true if the column is a numeric
{{ numeric_column.is_numeric() }}
-- Return true if the column is a number
{{ numeric_column.is_number() }}
-- Return true if the column is an integer
{{ numeric_column.is_integer() }}
-- Return true if the column is a float
{{ numeric_column.is_float() }}

-- Static methods
-- Return the string data type for this database adapter with a given size
{{ api.Column.string_type(255) }}
-- Return the numeric data type for this database adapter with a given precision and scale
{{ api.Column.numeric_type('numeric', 12, 4) }}
```

# BigQuery columns

The `Column` type is overridden as a `BigQueryColumn` in BigQuery dbt projects. This object works the same as the `Column` type described above, with the exception of extra properties and methods:

### Properties
*   **fields**: Returns the list of subfields contained within a field (if the column is a STRUCT)
*   **mode**: Returns the "mode" of the column, eg. `REPEATED`

### Instance methods
**flatten()**: Return a flattened list of `BigQueryColumns` in which subfields are expanded into their own columns. For example, this nested field:

```json
[{"hits": {"pageviews": 1, "bounces": 0}}]
```

will be expanded to:

```json
[{"hits.pageviews": 1, "hits.bounces": 0}]
```

# Result objects

The execution of a resource in dbt generates a `Result` object. This object contains information about the executed node, timing, status, and metadata returned by the adapter. At the end of an invocation, dbt records these objects in `run_results.json`.

*   `node`: Full object representation of the dbt resource (model, seed, snapshot, test) executed, including its `unique_id`
*   `status`: dbt's interpretation of runtime success, failure, or error
*   `thread_id`: Which thread executed this node? E.g. `Thread-1`
*   `execution_time`: Total time spent executing this node, measured in seconds.
*   `timing`: Array that breaks down execution time into steps (often `compile` + `execute`)
*   `message`: How dbt will report this result on the CLI, based on information returned from the database
*   `adapter_response`: Dictionary of metadata returned from the database, which varies by adapter. For example, success `code`, number of `rows_affected`, total `bytes_processed`, and so on. Not applicable for tests.
*   `rows_affected` returns the number of rows modified by the last statement executed. In cases where the query's row count can't be determined or isn't applicable (such as when creating a view), a standard value of `-1` is returned for `rowcount`.
