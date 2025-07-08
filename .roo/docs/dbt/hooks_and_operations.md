# Related documentation

*   pre-hook & post-hook
*   on-run-start & on-run-end
*   `run-operation` command

### Assumed knowledge

*   Project configurations
*   Model configurations
*   Macros

# Getting started with hooks and operations

Effective database administration sometimes requires additional SQL statements to be run, for example:

*   Creating UDFs
*   Managing row- or column-level permissions
*   Vacuuming tables on Redshift
*   Creating partitions in Redshift Spectrum external tables
*   Resuming/pausing/resizing warehouses in Snowflake
*   Refreshing a pipe in Snowflake
*   Create a share on Snowflake
*   Cloning a database on Snowflake

dbt provides hooks and operations so you can version control and execute these statements as part of your dbt project.

# About hooks

Hooks are snippets of SQL that are executed at different times:

*   `pre-hook`: executed _before_ a model, seed or snapshot is built.
*   `post-hook`: executed _after_ a model, seed or snapshot is built.
*   `on-run-start`: executed at the _start_ of`dbt build`, `dbt compile`, `dbt docs generate`, `dbt run`, `dbt seed`, `dbt snapshot`, or `dbt test`.
*   `on-run-end`: executed at the _end_ of`dbt build`, `dbt compile`, `dbt docs generate`, `dbt run`, `dbt seed`, `dbt snapshot`, or `dbt test`.

Hooks are a more-advanced capability that enable you to run custom SQL, and leverage database-specific actions, beyond what dbt makes available out-of-the-box with standard materializations and configurations.

If (and only if) you can't leverage the `grants` resource-config, you can use `post-hook` to perform more advanced workflows:

*   Need to apply `grants` in a more complex way, which the dbt Core `grants` config doesn't (yet) support.
*   Need to perform post-processing that dbt does not support out-of-the-box. For example, `analyze table`, `alter table set property`, `alter table ... add row access policy`, etc.

### Examples using hooks

You can use hooks to trigger actions at certain times when running an operation or building a model, seed, or snapshot.

For more information about when hooks can be triggered, see reference sections for `on-run-start` and `on-run-end` hooks and `pre-hook`s and `post-hook`s.

You can use hooks to provide database-specific functionality not available out-of-the-box with dbt. For example, you can use a `config` block to run an `ALTER TABLE` statement right after building an individual model using a `post-hook`:

**models/<model_name>.sql**
```sql
{{ config(
    post_hook=[
      "alter table {{ this }} ..."
    ]
) }}
```

### Calling a macro in a hook

You can also use a macro to bundle up hook logic. Check out some of the examples in the reference sections for on-run-start and on-run-end hooks and pre- and post-hooks.

**models/<model_name>.sql**
```sql
{{ config(
    pre_hook=[
      "{{ some_macro() }}"
    ]
) }}
```

**models/properties.yml**
```yml
models:
  - name: <model_name>
    config:
      pre_hook:
        - "{{ some_macro() }}"
```

**dbt_project.yml**
```yml
models:
  <project_name>:
    +pre-hook:
      - "{{ some_macro() }}"
```

# About operations

Operations are macros that you can run using the `run-operation` command. As such, operations aren't actually a separate resource in your dbt project — they are just a convenient way to invoke a macro without needing to run a model.

Unlike hooks, you need to explicitly execute a query within a macro, by using either a statement block or a helper macro like the run_query macro. Otherwise, dbt will return the query as a string without executing it.

This macro performs a similar action as the above hooks:

**macros/grant_select.sql**
```sql
{% macro grant_select(role) %}
{% set sql %}
    grant usage on schema {{ target.schema }} to role {{ role }};
    grant select on all tables in schema {{ target.schema }} to role {{ role }};
    grant select on all views in schema {{ target.schema }} to role {{ role }};
{% endset %}
{% do run_query(sql) %}
{% do log("Privileges granted", info=True) %}
{% endmacro %}
```

To invoke this macro as an operation, execute `dbt run-operation grant_select --args '{role: reporter}'`.

```bash
$ dbt run-operation grant_select --args '{role: reporter}'
Running with dbt=1.6.0
Privileges granted
```

Full usage docs for the `run-operation` command can be found here.

# Additional examples

These examples from the community highlight some of the use-cases for hooks and operations!

*   In-depth discussion of granting privileges using hooks and operations, for dbt Core versions prior to 1.2
*   Staging external tables
*   Performing a zero copy clone on Snowflake to reset a dev environment
*   Running `vacuum` and `analyze` on a Redshift warehouse
*   Creating a Snowflake share
*   Unloading files to S3 on Redshift
*   Creating audit events for model timing
*   Creating UDFs
