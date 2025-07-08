# dbt Seed Data Type Configuration

When defining column data types in a `seed.yml` file, do not use hardcoded data types as they are not cross-database compatible. Instead, use conditional Jinja logic based on the `target.type` to ensure the correct data types are used for each adapter.

**Correct:**
```yaml
version: 2

seeds:
  - name: my_seed
    config:
      column_types:
        my_column: "{% if target.type == 'snowflake' %}NUMBER{% elif target.type == 'bigquery' %}INT64{% endif %}"
```

**Incorrect:**
```yaml
version: 2

seeds:
  - name: my_seed
    config:
      column_types:
        my_column: integer
```

**Incorrect:**
```yaml
version: 2

seeds:
  - name: my_seed
    config:
      column_types:
        my_column: "{{ dbt.type_int() }}"