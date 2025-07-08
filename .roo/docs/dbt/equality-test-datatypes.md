# dbt_utils.equality Test Data Type Requirement

When using the `dbt_utils.equality` generic test to compare a model's output against a seed file, it is **critical** to define the `column_types` for the seed in its corresponding `.yml` configuration file.

## The Problem

The `equality` test performs a comprehensive comparison, which includes checking for data type consistency between the two relations. If the data types are not explicitly defined for the seed, dbt may infer them differently across various database adapters (e.g., Snowflake vs. BigQuery). This will lead to test failures, even if the data values themselves are identical.

## The Solution

Always create a `.yml` file for your expected-result seed files and explicitly define the `column_types` for every column. Use conditional Jinja logic based on `target.type` to ensure the correct data types are used for each supported adapter.

**Correct:**
```yaml
# integration_tests/seeds/expected_my_model.yml
version: 2

seeds:
  - name: expected_my_model
    config:
      column_types:
        user_id: "{% if target.type == 'snowflake' %}NUMBER{% elif target.type == 'bigquery' %}INT64{% endif %}"
        user_name: "{% if target.type == 'snowflake' %}VARCHAR{% elif target.type == 'bigquery' %}STRING{% endif %}"
```

By explicitly defining the data types, you ensure that the `equality` test can perform a reliable, cross-database comparison, leading to more robust and accurate data validation.