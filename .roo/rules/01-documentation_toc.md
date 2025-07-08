# Documentation Table of Contents

This file provides a central index for all external documentation that has been integrated into the project's rules. **You should consult these documents as needed to ensure you are following the correct patterns and conventions.**

## BigQuery Documentation

*   [BigQuery Data Types](../docs/bigquery/bigquery-data_types.md): Provides an overview of all GoogleSQL for BigQuery data types, including information about their value domains.

## dbt Documentation

*   [Adapter Dispatch](../docs/dbt/adapter_dispatch.md): Explains how to use dbt's `adapter.dispatch` mechanism to extend functionality across different database platforms.
*   [dbt Classes](../docs/dbt/classes.md): Describes the dbt classes like `Relation` and `Column` that represent objects in a data warehouse.
*   [Cross-Database Macros](../docs/dbt/cross_database_macros.md): A reference for all of dbt's cross-database macros, which help in writing database-agnostic SQL.
*   [Cross-Database Type Checking](../docs/dbt/cross_database_type_checking.md): Outlines the best practice for checking column data types in a cross-database compatible way using built-in methods.
*   [Debugging and Output Macros](../docs/dbt/debug-macros.md): Provides best practices for creating helper macros for debugging, including how to handle console output and logging.
*   [Equality Test Data Types](../docs/dbt/equality-test-datatypes.md): Explains the importance of defining explicit `column_types` for seeds when using the `dbt_utils.equality` test.
*   [Hooks and Operations](../docs/dbt/hooks_and_operations.md): Details how to use dbt hooks (`pre-hook`, `post-hook`) and operations (`run-operation`) to execute custom SQL.
*   [Logging Configs](../docs/dbt/logging_configs.md): Covers how to configure dbt's logging, including log formats, levels, and output paths.
*   [Macro Calling Convention](../docs/dbt/macro_calling_convention.md): Defines the golden rule of always prefixing macro calls with their parent package name for robust resolution.
*   [dbt Packages](../docs/dbt/packages.md): Explains how to use and create dbt packages.
*   [run-operation Command](../docs/dbt/run_operation.md): Explains the usage of the `dbt run-operation` command to invoke a macro from the command line.
*   [run_query Macro](../docs/dbt/run_query.md): Describes the `run_query` macro for executing queries and fetching results within a dbt project.
*   [Seed Data Types](../docs/dbt/seed_datatypes.md): Specifies the correct way to define column data types in a `seed.yml` file for cross-database compatibility.
*   [Integration Test Execution](../docs/dbt/testing_execution.md): Mandates that all integration test scripts must be executed from within the `integration_tests/` directory.
*   [Unit Test Introspection Limitations](../docs/dbt/unit_test_introspection_limitations.md): Highlights the incompatibility of dbt unit tests with macros that use introspection and recommends using data tests instead.

## dbt_utils Package

*   [dbt_utils README](../docs/dbt_utils/readme.md): The official README for the `dbt-utils` package, containing a comprehensive overview of its macros and generic tests.
