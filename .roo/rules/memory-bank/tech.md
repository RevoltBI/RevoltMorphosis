# Technology Stack

## Technologies Used

*   **dbt**: The core framework for building the data transformation package.
*   **SQL**: The primary language for writing macros and models.
*   **Jinja**: Used within dbt for templating and control flow in macros.
*   **Snowflake**: One of the target database platforms.
*   **BigQuery**: The second target database platform.
*   **Shell Script**: Used for orchestrating integration tests (`run_integration_tests.sh`).
*   **GitHub Actions**: Used for Continuous Integration to automate the execution of integration tests.
*   **YAML**: Used for dbt project configurations and model properties.
*   **JSON**: Used to pass arguments to dbt operations.

## Development Setup

*   The project is structured as a dbt package, with the main source code in the `/macros` and `/tests/generic` directories.
*   Testing is conducted within the `/integration_tests` directory, which is a standalone dbt project that installs the parent package.
*   Developers should run all dbt commands from the `/integration_tests` directory.
*   The `integration_tests/run_integration_tests.sh` script is the primary entry point for running a full suite of tests against a target database.
*   **Line Endings**: To ensure consistency across all development environments, the project uses a `.gitattributes` file to enforce Unix-style line endings (`LF`) for all text-based files.

## Technical Constraints

*   All macros must be cross-database compatible, functioning identically on both Snowflake and BigQuery unless explicitly documented otherwise.
*   Breaking changes to macro signatures should be avoided if possible, and clearly documented when necessary.

## Dependencies

*   The core package has no external dbt package dependencies.
*   The `integration_tests` project has a local dependency on the root package, defined in `integration_tests/packages.yml`.

## Tool Usage Patterns

*   **dbt Operations**: Imperative actions, such as generating test data, are implemented as `dbt run-operation` commands.
*   **Operation Arguments**: Complex arguments for operations are passed via JSON files (e.g., `create_multiple_random_data_tables_args.json`) to simplify the CLI call.
*   **Cross-Database Logic**: The `adapter.dispatch` method is used to manage SQL syntax differences between Snowflake and BigQuery.
*   **Seeding**: `dbt seed` is used to load static CSV data required for integration tests.