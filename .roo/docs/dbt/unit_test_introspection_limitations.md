# dbt Unit Test Introspection Limitations

When writing dbt unit tests, it is critical to understand that they are incompatible with macros that use introspection to dynamically inspect database relations.

## The Problem

Macros that rely on `adapter.get_columns_in_relation()` to get the schema of a source table will fail during unit testing. This is because unit tests operate on temporary, in-memory CTEs created from the mock data in the `given` block. The `adapter.get_columns_in_relation()` function cannot "see" the columns of these ephemeral CTEs, as they do not exist as persistent relations in the database when the macro is being compiled.

This will result in the function returning an empty list of columns, leading to compilation errors (e.g., `CONCAT() with no arguments`) or unexpected behavior.

## The Solution

For macros that must use introspection, you must use **data tests** (also known as integration tests) instead of unit tests. This involves:

1.  **Running the model**: Materialize the model in your test environment to create a real table.
2.  **Testing the output**: Write data tests (e.g., using `dbt_utils.expression_is_true` or custom generic tests) that query the resulting table to validate its contents and structure.

This approach ensures that the macro's introspective logic has a real database object to inspect, allowing for accurate and reliable testing.