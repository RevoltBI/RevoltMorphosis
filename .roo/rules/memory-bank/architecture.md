# Architecture

## System Architecture

This project is a dbt package. The architecture is centered around a set of reusable macros designed to be imported into other dbt projects. The package's own structure separates the macro source code from the integration tests used for development and validation.

## Source Code Paths

*   `/macros`: Contains the source code for all dbt macros provided by the package.
    *   `/macros/generate_data`: Contains the `create_multiple_random_data_tables` operation and its helper macro `create_random_data_table` for generating test data.
*   `/tests/generic`: Contains the custom generic tests provided by the package.
*   `/integration_tests`: A self-contained dbt project used to test the functionality of the main package. It installs the package from the root directory.
    *   `/integration_tests/macros/read_table.sql`: A helper macro for debugging that prints the contents of a table in a readable format or as a clean CSV.

## Key Technical Decisions

*   The primary dbt project for testing is located in the `integration_tests/` directory, not the root, to ensure a clean separation between package code and test code.
*   The `anonymize_data` macro was refactored to use the cross-database `dbt.hash()` macro for better performance and compatibility.
*   The `populate_tables` macro was refactored into a `dbt run-operation` and has been decomposed into two new macros: `create_multiple_random_data_tables` (the user-facing operation) and `create_random_data_table` (the internal, single-table implementation). The internal macro now accepts an explicit `target_table_name` and has default values for most arguments, improving its flexibility and robustness.
*   The data generation macros (`create_random_data_table` and `create_multiple_random_data_tables`) have been refactored to accept SQL expressions for random data generation, removing the need for the `dataseeds` macros. This simplifies the codebase and provides more flexibility to the user.
*   The `cleanup` macro was renamed to `drop_orphaned_objects` to more accurately reflect its function of removing orphaned relations and schemas from the database.
*   The documentation files have been moved from `.roo/rules/docs` to `.roo/docs` to prevent them from being automatically loaded into the context, with a `documentation_toc.md` file to serve as a central index.
*   A GitHub Actions workflow has been implemented to automate integration tests for Snowflake and BigQuery. It currently uses a static schema defined by a repository variable (`DBT_SCHEMA`) to simplify debugging. The long-term goal is to move to dynamic, run-specific schemas with automated cleanup.

## Design Patterns in Use

*   **Cross-Database Compatibility**: Macros are designed to work across multiple database platforms (Snowflake, BigQuery) by using dbt's cross-database macros and adapter dispatching wherever possible.
*   **Imperative Actions as Operations**: Procedural actions like generating test data are implemented as `dbt run-operation`s rather than being embedded in model `pre-hook`s. This separates imperative setup from the declarative nature of dbt models.
*   **Configuration via JSON**: Arguments for `run-operation`s are passed via JSON files (e.g., `create_multiple_random_data_tables_args.json`) to keep CLI commands simple and configurations version-controlled.
*   **Macro Calling Convention**: To ensure robust and predictable macro resolution, all macro calls—both in Jinja and in `dbt run-operation` commands—must be explicitly prefixed with their parent package name. The only exception is for calls between macros that are managed by dbt's `adapter.dispatch` mechanism, which do not require a prefix. This convention is enforced by a rule in `.roo/rules-code/dbt-macro_calling_convention.md`.
*   **Private Macro Naming**: Internal helper macros that are not intended for direct use by the end-user are prefixed with a double underscore (`__`). This applies to both the filename and the macro name itself. This convention is enforced by a rule in `.roo/rules/private-macro-convention.md`.
*   **Transient Model Identification**: Transient models, which are dropped at the end of a run, are identified using a configurable tag. The `drop_transient_models` macro accepts a `transient_tag` argument, which defaults to `RevoltMorphosis_transient`. This provides a clear and flexible way to manage the lifecycle of temporary models.
*   **CI/CD with GitHub Actions**: The project uses a GitHub Actions workflow located at `.github/workflows/integration_tests.yml` to run integration tests on push and pull_request to the `main` branch. It uses a matrix strategy to test against multiple databases. Secrets are handled securely using GitHub Secrets and masked logging commands. Configuration is managed via GitHub Repository Variables.

## Component Relationships

*   The macros in `/macros` are the core components.
*   The models in `/integration_tests/models` consume these macros to test their functionality. Test models are named after the macro or generic test they are validating (e.g., `test_standardize_model.sql`).
*   The generic test in `/tests/generic` is applied to models within the integration test project to validate data integrity.

## Critical Implementation Paths

*   Ensuring all macros are fully compatible with both Snowflake and BigQuery is the most critical path. This involves careful use of dbt's adapter functionality and thorough testing against both platforms.
