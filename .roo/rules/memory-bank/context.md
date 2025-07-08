# Context

## Recent changes

*   The `drop_transient_models` macro has been significantly improved for safety and reliability. It now uses `adapter.get_relation` to ensure a model's relation exists before attempting to drop it, preventing errors for models that failed to build. The macro also filters the `results` object to only process actual models and features enhanced logging for better debugging.
*   A `.gitattributes` file has been added to the root of the repository to enforce consistent, Unix-style (`LF`) line endings for all text-based files. Existing files have been renormalized, and the change has been verified with integration tests.

*   The `README.md` has been updated to include a new section on `Environment Variables` under `Integration Tests`. This section documents the purpose and structure of the `integration_tests/.env` file, which is required for running the tests. It also now includes a dedicated "Test Scripts" section, mentions the `run_drop_orphaned_objects_test.sh` script, and clarifies that the `.env` file must be created before launching the devcontainer.

*   The documentation files have been moved from `.roo/rules/docs` to `.roo/docs` to prevent them from being automatically loaded into the context, and the paths in `documentation_toc.md` have been updated.

*   Several dbt documentation files in `.roo/rules/docs/dbt` have been refactored to improve readability and conciseness. This involved removing boilerplate content, standardizing headings, and fixing code block formatting.
*   The `bigquery-data_types.md` documentation has been refactored to be more concise and developer-friendly. The new format improves scannability and focuses on essential information.
*   The rules documentation has been reorganized into a new `docs` directory with subdirectories for `dbt`, `bigquery`, and `dbt_utils`. A table of contents file has been added to make the documentation easier to navigate.
*   The `read_table` integration test macro has been enhanced to provide more flexible output. It now supports a `limit` argument, can output a properly formatted and escaped CSV, when using the `--quiet` flag to suppress dbt logging for clean, redirectable output.
*   The integration tests for the `anonymize_data` and `standardize_model` macros have been significantly improved by replacing less precise checks with the `dbt_utils.equality` test. This ensures that the transformations produce the exact, expected output.
*   The entire testing suite has been refactored. The project now uses robust data tests to validate macro behavior, ensuring cross-database compatibility. The test models have been clarified, and the test execution script is verified to run all tests correctly.
*   The `anonymize_data` macro has been corrected to restore its original behavior, where the specified column is replaced by a hash and a new column with a configurable suffix (`_ORIGINAL` by default) is created to hold the original value.
*   The `standardize_model` macro was fixed to ensure the `empty_to_null` functionality works correctly on BigQuery by using the `column.is_string()` method for cross-database type checking.
*   The integration test models have been refactored for clarity and maintainability. The `input_model` directory was removed, and test models are now named after the macro or generic test they validate (e.g., `test_standardize_model.sql`). All test models now use the `test_table` seed as their single source of data.
*   The data generation macros (`create_random_data_table` and `create_multiple_random_data_tables`) have been refactored to accept SQL expressions for random data generation, removing the need for the `dataseeds` macros. This simplifies the codebase and provides more flexibility to the user.
*   The logic for uppercasing column names in the `generate_randomly` argument has been moved from the `create_multiple_random_data_tables` macro to the `create_random_data_table` macro. This makes the "scalar" macro more robust and self-contained.
*   The `drop_orphaned_objects.sql` has been refactored to reduce code duplication in the `relations_query` by creating a reusable `select_clause` variable. This simplifies the macro and improves maintainability.
*   The `drop_orphaned_objects` macro has been refactored to improve code quality, readability, and maintainability. This includes:
    *   Using `adapter.dispatch` to handle cross-database logic for Snowflake and BigQuery.
    *   Simplifying the logic for identifying orphaned relations and schemas.
    *   Adding a default value for the `objects_type` parameter.
    *   Improving the integration tests to cover the actual execution of the macro.
*   The `randomdata` macro has been refactored to use the `randomfact` and `randomfloat` macros for consistent data generation across Snowflake and BigQuery.
*   A new `randomfloat` macro was created to generate random floating-point numbers, with implementations for both Snowflake and BigQuery.
*   The test suite was updated to include a `revenue` float column and a `location` geo-coordinate column to validate the new data generation logic.
*   The `populate_tables` macros for both Snowflake and BigQuery were updated to use the `randomfloat` macro for float columns.
*   A new rule was added to the `.roo/rules-code` directory to enforce the correct dbt macro calling convention.
*   The `populate_tables` macro has been successfully refactored into a `dbt run-operation`.
*   The `populate_tables` macro implementations for both Snowflake and BigQuery have been significantly refactored to be more robust and consistent. This includes:
    *   Standardized table referencing using `api.Relation.create`.
    *   Ensured data types are preserved correctly.
    *   Aligned filtering logic for empty strings.
    *   Removed `DISTINCT` to better replicate source data distribution.
    *   Improved cleanup of temporary tables in the BigQuery implementation.
    *   Replaced the confusing `reuse_columns` and `keep_reuse_columns` arguments with the more explicit `sample_from_source` and `generate_randomly` arguments.
*   The `randomdate` macro has been refactored to be cross-database compatible using `adapter.dispatch`.
*   The `populate_tables` operation has been refactored and renamed. It is now `create_multiple_random_data_tables`, which calls the new, internal `create_random_data_table` macro for each table. The internal macro now accepts an explicit `target_table_name` and has default values for most arguments, improving its flexibility and robustness.
*   The `generate_data_example2_base` seed and all its references have been renamed to `test_table` to better reflect its purpose.
*   Fixed a bug in the `drop_orphaned_objects` macro where it was incorrectly identifying legitimate seed tables as orphans on BigQuery. The issue was resolved by ensuring that relation names from the dbt graph and the database are compared in a consistent, unquoted format.
*   The `cleanup` macro and its corresponding file have been renamed to `drop_orphaned_objects` to better reflect their purpose.
