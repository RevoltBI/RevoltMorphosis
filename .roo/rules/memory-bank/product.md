# Product

## Why this project exists

This project is a dbt package named RevoltMorphosis. It exists to solve common data transformation and quality challenges within dbt projects, especially those needing to work across multiple database platforms like Snowflake and BigQuery. The core problem it addresses is the need for standardized, clean, and non-sensitive data for analytics, along with robust testing to ensure data integrity.

## How it should work

The package provides a collection of dbt macros that users can easily incorporate into their projects to perform specific tasks:

*   **`standardize_model`**: Cleans and standardizes dbt models by handling column naming conventions, generating surrogate keys, and managing empty string values.
*   **`anonymize_data`**: Anonymizes sensitive data, such as Personally Identifiable Information (PII), by hashing it.
*   **`is_missing_in_target_table`**: A generic data test to verify that no records are lost when transforming data between models.
*   **`create_multiple_random_data_tables`**: A `run-operation` to generate realistic test data, which can also be anonymized.

## User Experience Goals

The primary goal is to provide a simple and intuitive experience for data engineers. The macros should be well-documented, easy to configure, and abstract away the complexities of cross-database SQL syntax. Users should be able to apply these powerful data quality and governance features with minimal effort.