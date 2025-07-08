# RevoltMorphosis

This [dbt](https://github.com/dbt-labs/dbt) package contains macros that can be (re)used across dbt projects.

Supported adapters:
- Snowflake (dbt-snowflake==1.9.1)
- BigQuery (dbt-bigquery==1.9.1)

## Installation Instructions

To install our Revolt BI package put the code below into your `packages.yml` and run `dbt deps`.

```
packages:
  - git: "https://github.com/RevoltBI/RevoltMorphosis"
    revision: 2.0.2
```

----
<!--This table of contents is automatically generated. Any manual changes between the ts and te tags will be overridden!-->
<!--ts-->
   * [Installation Instructions](#installation-instructions)
   * [Macros](#macros)
      * [Standardize model macro](#standardize-model-macro)
      * [Anonymize data macro](#anonymize-data-macro)
      * [Create random data table macro](#create-random-data-table-macro)
      * [Drop orphaned objects macro](#drop-orphaned-objects-macro)
      * [Inspect relation macro](#inspect-relation-macro)
      * [Drop transient models macro](#drop-transient-models-macro)
   * [Generic Tests](#generic-tests)
      * [Is missing in target table](#is-missing-in-target-table)
   * [Operations](#operations)
      * [Create multiple random data tables operation](#create-multiple-random-data-tables-operation)
   * [Integration Tests](#integration-tests)
<!--te-->
----

## Macros

### Standardize model macro
([source](macros/standardize_model.sql))

Standardize model macro is a perfect fit for whenever you want to standardize your source table or referenced model with some easy clean ups and unified form.

#### Why should I use this macro?
1. Standardize column naming convention (convert all columns to uppercase / lowercase - avoid using double quotes).
2. Create unified surrogate keys across project.
3. Clean up empty strings from your table (replace them with null values).
4. Exclude columns from your output but still clean the data.

#### Usage
Example of the simplest usage you can do for:
- Source: `{{ RevoltMorphosis.standardize_model(source("source_name","source_table")) }}`.
- Referenced model: `{{ RevoltMorphosis.standardize_model(ref("input_model")) }}`.

#### Parameters
Standardize model macro currently has multiple parameters.
1. [relation](#relation)
2. [exclude_columns](#exclude-columns)
3. [columns_mode](#columns-mode)
4. [empty_to_null](#empty-to-null)
5. [surrogate_key_columns](#surrogate-key-columns)
6. [surrogate_key_delimiter](#surrogate-key-delimiter)
7. [hash_surrogate_key](#hash-surrogate-key)

##### Relation
Type: Required.
Input type: ref() or source() macro

*Example*
- Source: `{{ RevoltMorphosis.standardize_model(source("source_name","source_table")) }}`.
- Referenced model: `{{ RevoltMorphosis.standardize_model(ref("input_model")) }}`.

##### Exclude columns
Type: Optional.
Input type: Array
List of columns you want to exclude from output.

*Example*

`{{ RevoltMorphosis.standardize_model(ref("input_model"),excluded_columns=["Name"]) }}`.

Input model:
| id | Name   | Email |
|----|--------|-------|
| 1  | Joseph |       |
| 2  |        |       |

Output model:
| id | Email |
|----|-------|
| 1  |       |
| 2  |       |

##### Columns mode
Type: Optional.
Input type: String
Default value: 'upper'
String value to convert column names to uppercase, lowercase, title, capitalize or keep the input format (keep).

*Example*

`{{ RevoltMorphosis.standardize_model(ref("input_model"),columns_mode="upper") }}`.

Input model:
| id | Name   | Email |
|----|--------|-------|
| 1  | Joseph |       |
| 2  |        |       |

Output model:
| ID | NAME   | EMAIL |
|----|--------|-------|
| 1  | Joseph |       |
| 2  |        |       |

*Values*

| columns_mode | Example            |
|--------------|--------------------|
| upper        | COLUMN_NAME        |
| lower        | column_name        |
| title        | Column_Name        |
| capitalize   | Column_name        |
| keep         | keeps input format |

##### Empty to null
Type: Optional.
Input type: Boolean
Default value: false
Converts empty string (varchar) values to NULL values instead

*Example*

`{{ RevoltMorphosis.standardize_model(ref("input_model"),empty_to_null=true) }}`.

Input model:
| id | Name   | Email |
|----|--------|-------|
| 1  | Joseph |       |

Output model:
| id | Name    | Email |
|----|---------|-------|
| 1  | Joseph  | null  |

##### Surrogate key columns
Type: Optional.
Input type: Array
Default value: [] (do not create a surrogate key)
List of columns from which you want to create a surrogate key.
Surrogate key column name will be lower "surrogate_key" unless differently specified with columns_mode attribute

*Example*

`{{ RevoltMorphosis.standardize_model(ref("input_model"),surrogate_key_columns=["id","Name"]) }}`.

Input model:
| id | Name    |
|----|---------|
| 1  | Joseph  |
| 2  | Phillip |

Output model:
| surrogate_key | id | Name    |
|---------------|----|---------|
| 1-Joseph      | 1  | Joseph  |
| 2-Phillip     | 2  | Phillip |

##### Surrogate key delimiter
Type: Optional.
Input type: String
Default value: '-'
Delimiter you want to use to create the surrogate key.

*Example*

`{{ RevoltMorphosis.standardize_model(ref("input_model"),surrogate_key_columns=["id","Name"],surrogate_key_delimiter='_') }}`.


Input model:
| id | Name   |
|----|--------|
| 1  | Joseph |
| 2  | Phillip|

Output model:
| surrogate_key | id | Name    |
|---------------|----|---------|
| 1_Joseph      | 1  | Joseph  |
| 2_Phillip     | 2  | Phillip |

##### Hash surrogate key
Type: Optional.
Input type: Boolean
Default value: false
Boolean value whether to convert hash the surrogate key columns
using [dbt_utils.generate_surrogate_key](https://github.com/dbt-labs/dbt-utils?tab=readme-ov-file#generate_surrogate_key-source) macro.

*Example*

`{{ RevoltMorphosis.standardize_model(ref("input_model"),surrogate_key_columns=["id","Name"],hash_surrogate_key=true) }}`.

Input model:
| id | Name   |
|----|--------|
| 1  | Joseph |

Output model:
| surrogate_key | id | Name    |
|---------------|----|---------|
| c1a365419f5ab09a2c46ddc95109dce9 | 1  | Joseph  |

---

### Anonymize data macro
([source](macros/anonymize_data.sql))

Anonymize data macro does your job for hashing PII or any other sensitive information, all the columns you define to be hashed will be hashed so
a user can not find out the real data.

#### Why should I use this macro?
1. You don't want to show PII.
2. You don't want to show sensitive data.

#### Usage
Example of the simplest usage you can do for:
- referenced model: `{{ RevoltMorphosis.anonymize_data(ref("input_model"),anonymized_columns=["ID"]) }}`.

#### Parameters
The `anonymize_data` macro has been refactored for simplicity and cross-database compatibility. It now uses the `dbt.hash()` macro to anonymize data.

1. [relation](#relation-anonymization)
2. [anonymized_columns](#anonymized-columns)
3. [create_new_column](#create-new-column)
4. [original_value_suffix](#original-value-suffix)

##### Relation anonymization
Type: Required.
Input type: ref() or source() macro

*Example*
- Referenced model: `{{ RevoltMorphosis.anonymize_data(ref("input_model"), anonymized_columns=["id"]) }}`.

##### Anonymized columns
Type: Required.
Input type: Array
List of columns you want to anonymize.

*Example*

`{{ RevoltMorphosis.anonymize_data(ref("input_model"),anonymized_columns=["id","Name"]) }}`.

Input model:
| id | Name   |
|----|--------|
| 1  | Joseph |

Output model:
| id                               | Name                             |
|----------------------------------|----------------------------------|
| c1a365419f5ab09a2c46ddc95109dce9 | 1b2a3339ed3722454990623f518496a8 |

##### Create new column
Type: Optional.
Input type: Boolean
Default value: True
If set to `True`, the macro will create a new column with the original value.

*Example*

`{{ RevoltMorphosis.anonymize_data(ref("input_model"),anonymized_columns=["id"],create_new_column=True) }}`.

Input model:
| id | Name   |
|----|--------|
| 1  | Joseph |

Output model:
| Name   | id                               | id_ORIGINAL |
|--------|----------------------------------|-------------|
| Joseph | c1a365419f5ab09a2c46ddc95109dce9 | 1           |

##### Original value suffix
Type: Optional.
Input type: String
Default value: '_ORIGINAL'
The suffix to be added to the new column containing the original value.

*Example*

`{{ RevoltMorphosis.anonymize_data(ref("input_model"),anonymized_columns=["ID"],create_new_column=True, original_value_suffix='_OLD') }}`.

Input model:
| ID | NAME   |
|----|--------|
| 1  | Joseph |

Output model:
| NAME   | ID                               | ID_OLD |
|--------|----------------------------------|--------|
| Joseph | c1a365419f5ab09a2c46ddc95109dce9 | 1      |

---

### Create random data table macro
([source](macros/generate_data/create_random_data_table.sql))

This is an internal helper macro used by the `create_multiple_random_data_tables` operation to generate data for a single table. By default, it samples data from the source table. It is not intended to be called directly by end-users.

#### Parameters

1.  `table_name` (Required, String): The name of the source table to use as a template for the new table's schema.
2.  `target_table_name` (Required, String): The name of the new table that will be created.
3.  `num_lines` (Optional, Integer): The number of random rows to generate. Default: `100`.
4.  `generate_randomly` (Optional, Dictionary): A dictionary where keys are column names and values are the SQL expressions to be used for generating random data for those columns. Default: `{}`.

#### Example

```sql
{{ RevoltMorphosis.create_random_data_table(
    table_name='my_source_table',
    target_table_name='my_target_table',
    num_lines=1000,
    generate_randomly={
        'AGE': 'CAST((RAND() * (99 - 18)) + 18 AS INT64)',
        'REVENUE': 'RAND() * (1000 - 50) + 50'
    }
) }}
```

---

### Drop orphaned objects macro
([source](macros/drop_orphaned_objects.sql))

The drop_orphaned_objects macro helps you remove orphaned tables and schemas from your database that are no longer managed by dbt, such as deleted models or custom schemas from team members.

#### Why should I use this macro?
1. By removing orphaned tables and unused schemas, you reduce database clutter
2. Cleaning up unnecessary data helps to minimize storage costs
3. Keeping your database tidy makes it easier to manage and maintain.
4. Ensuring that only relevant and current objects are present in the database helps maintain the integrity of your data and reduces the likelihood of using outdated or incorrect information.

#### Usage
Example of the simplest usage you can do to list tables for clean up:
```bash
dbt run-operation drop_orphaned_objects --args '{"objects_type": ["base table"]}'
```

To actually clean up tables and schemas use following comand:
```bash
dbt run-operation drop_orphaned_objects --args '{"objects_type": ["base table"], "dry_run": false}'
```

#### Parameters and default values
The `drop_orphaned_objects` macro has the following parameters:

1.  `objects_type` (Optional, Array): A list of object types to be dropped. Default: `['BASE TABLE', 'VIEW']`. Available object types are `VIEW`, `BASE TABLE`, `MANAGED`.
2.  `dry_run` (Optional, Boolean): If `true`, the macro logs the drop commands without executing them. If `false`, the macro executes the drop commands. Default: `true`.
3.  `tables_to_exclude` (Optional, Array): A list of table names to exclude from being dropped. Default: `[]`.
4.  `schemas_to_exclude` (Optional, Array): A list of schema names to exclude from being dropped. Default: `[]`.
5.  `delete_custom_schemas` (Optional, Boolean): If `true`, the macro will drop schemas that are not managed by dbt. If `false`, it will only drop orphaned tables. Default: `false`.

##### Dry run
Input type: Boolean
Default value: True
If set to 'true', the macro logs the drop commands without executing them. If set to 'false', the macro executes the drop commands.

##### Tables to exclude
Input type: Array
A list of table names to exclude from being dropped.

*Example*:
```bash
dbt run-operation drop_orphaned_objects --args '{"objects_type": ["base table"], "dry_run": false, "tables_to_exclude": ["TABLE_NAME"]}'
```
The command will drop all tables except the "TABLE_NAME"

##### Schemas to exclude
Input type: Array
A list of schema names to exclude from being dropped.

*Example*:
```bash
dbt run-operation drop_orphaned_objects --args '{"objects_type": ["base table"], "dry_run": false, "schemas_to_exclude": ["SCHEMA_NAME"]}'
```
The command will drop all schemas except the "SCHEMA_NAME"

##### Delete Custom Schemas
Input type: Boolean
Default value: False
If set to 'true', the macro will drop schemas that are not managed by dbt. If set to 'false', it will only drop orphaned tables.

---

### Inspect relation macro
([source](macros/inspect_relation.sql))

The `inspect_relation` macro is a powerful debugging tool that allows you to inspect the contents of any table or view in your database. It can display the table's schema and a preview of its data directly in the console, or it can output the data as a clean, properly formatted CSV, which is ideal for redirecting to a file for further analysis.

#### Why should I use this macro?
1.  **Quickly inspect data**: View the schema and first few rows of any table without leaving your terminal.
2.  **Debug transformations**: Compare the output of a model with its input to verify that your logic is correct.
3.  **Export data for analysis**: Generate a clean CSV file from any table or view to use in other tools like Excel or Python.

#### Usage
The `inspect_relation` macro is designed to be called as a `dbt run-operation`.

**Default Behavior (Log to Console):**
This command will print the schema and the first 10 rows of the specified table to the console.
```bash
dbt run-operation inspect_relation --args '{"relation_name": "my_table_or_view"}'
```

**Clean CSV Output:**
This command will suppress all dbt logging and print only the raw, properly formatted CSV data for the first 20 rows of the table. This is perfect for redirecting to a file.
```bash
dbt --quiet run-operation inspect_relation --args '{"relation_name": "my_table_or_view", "limit": 20, "output_csv": true}' > my_output.csv
```

#### Parameters
1.  `relation_name` (Required, String): The name of the table or view you want to inspect.
2.  `limit` (Optional, Integer): The maximum number of rows to return. Default: `10`.
3.  `output_csv` (Optional, Boolean): If `true`, the macro will output the data as a clean CSV string. If `false`, it will log the schema and a data preview to the console. Default: `false`.

---

### Drop transient models macro
([source](macros/drop_transient_models.sql))

This macro provides a mechanism to automatically drop temporary or intermediate models at the end of a `dbt run`. This is useful for cleaning up models that are only needed during the run and should not persist in the database.

#### How it works

The macro is designed to be triggered by the `on-run-end` hook in your `dbt_project.yml`. It iterates through the results of the run, identifies any models configured as "transient", and drops them from the database.

#### Usage

1.  **Mark a model as transient:**
    Add the `RevoltMorphosis_transient` tag to your model. This can be done in the model's `.sql` file, in a `.yml` properties file, or for a group of models in your `dbt_project.yml`.

    *Example (`.sql` file):*
    ```sql
    {{ config(tags=['RevoltMorphosis_transient']) }}

    select * from {{ ref('some_intermediate_model') }}
    ```

    *Example (`.yml` file):*
    ```yaml
    models:
      - name: my_model
        config:
          tags:
            - "RevoltMorphosis_transient"
    ```

    *Example (`dbt_project.yml`):*
    ```yaml
    models:
      my_project:
        staging:
          +tags:
            - "RevoltMorphosis_transient"
    ```

2.  **Configure the `on-run-end` hook:**
    In your `dbt_project.yml`, add the following to call the macro at the end of each run. Note that this is already configured for the integration tests in this project.

    ```yaml
    on-run-end:
      - "{{ RevoltMorphosis.drop_transient_models(results) }}"
    ```

    You can also override the default transient tag (`RevoltMorphosis_transient`) by passing the `transient_tag` argument:
    ```yaml
    on-run-end:
      - "{{ RevoltMorphosis.drop_transient_models(results, transient_tag='my_custom_transient_tag') }}"
    ```

#### Parameters

*   `results` (Required, List): This is the `results` object that dbt provides in the `on-run-end` context. It contains information about the models that were run, which is necessary for the macro to identify which models to drop.
*   `transient_tag` (Optional, String): The tag used to identify transient models. Default: `'RevoltMorphosis_transient'`.

---

## Generic Tests

### Is missing in target table
([source](tests/generic/is_missing_in_target_table.sql))

This custom generic test allows you to check upstream vs. downstream models to see if you haven't accidentaly lost any data using JOIN or WHERE condition.

#### DISCLAMER

This custom generic test currently only works for uppercase column naming convention!

#### Why should I use this macro?
1. To see if you haven't accidentaly lost any data (column based).

#### Usage

Generic test is defined in .yml.

```
version: 2

models:
  - name: generic_test_model
    columns:
      - name: ID
        tests:
          - RevoltMorphosis.is_missing_in_target_table:
              to: ref('generic_test_input_model')
              field: ID
              source_where_condition: ID IS NOT NULL # Optional
```

This test compares values in ID from **generic_test_model** against column ID from **generic_test_input_model**. If an ID from **generic_test_input_model** is missing in **generic_test_model**, the test will fail.

To be able to cover WHERE conditions, you are allowed to filter the child (in this case **generic_test_input_model**) using source_where_condition parameter.

#### Parameters
1. [to](#to)
2. [field](#field)
3. [source_where_condition](#source-where-condition)

##### To
In `to` parameter please define the source table. Can be either:
- `source('source_name','source_table')`,
- `ref('referenced_model')`.

##### Field
In `field` parameter please define the column to compare it with in source data.

In the usage you can see the `field` parameter is ID, which means it will check the column ID from **generic_test_input_model**.

##### Source where condition

In `source_where_condition` you can define the conditions you can filter the source table with.
The condition needs to have a classic SQL syntax but there is no need to write the **WHERE** clause.

**Our macro does not check if the column really exists and neither the SQL syntax.**

*Example*

1. `source_where_condition: ID IS NOT NULL`  will create `WHERE ID IS NOT NULL`
2. `source_where_condition: ID IS NOT NULL AND ID != ''` will create `WHERE ID IS NOT NULL AND ID != ''`.

---

## Operations

### Create multiple random data tables operation
([source](macros/generate_data/create_multiple_random_data_tables.sql))

The `create_multiple_random_data_tables` operation allows you to generate and anonymize data for created tables based on your needs. This is now implemented as a `dbt run-operation`.

#### How to use

To use the `create_multiple_random_data_tables` operation, you will need to create a JSON file containing the arguments for the operation. Examples of these files can be found in `integration_tests/bigquery_create_multiple_random_data_tables_args.json` and `integration_tests/snowflake_create_multiple_random_data_tables_args.json`.

You can then run the operation using the following command:

```bash
dbt run-operation create_multiple_random_data_tables --args "$(cat path/to/your/args.json)"
```

For example, to run the integration tests, you can use the following command from the `integration_tests` directory:

```bash
dbt run-operation create_multiple_random_data_tables --args "$(cat your_adapter_create_multiple_random_data_tables_args.json)"
```

#### Parameters and default values

The `create_multiple_random_data_tables` operation accepts the following arguments in the JSON file:

-   `dimension_tables`: A list of dimension tables to be affected. Default: `[]`. At least one of `dimension_tables` or `fact_tables` must be provided.
-   `fact_tables`: A list of fact tables to be affected. Default: `[]`. At least one of `dimension_tables` or `fact_tables` must be provided.
-   `number_of_lines_dimension`: The number of rows to be generated for tables in `dimension_tables`. Default: `100`
-   `number_of_lines_fact`: The number of rows to be generated for tables in `fact_tables`. Default: `1000`
-   `prefix`: The prefix to add before generated tables (e.g., "DEMO_"). Default: `""`
-   `generate_randomly`: A dictionary where keys are column names and values are the SQL expressions to be used for generating random data for those columns. By default, all columns are sampled from the source.

#### `generate_randomly` behavior

Assume we have `DUMMY_TABLE` with columns `ID`, `NAME`, `AGE`.

##### Sample all columns from source (Default Behavior)

If `generate_randomly` is not provided or is an empty dictionary, all columns will be sampled from the source table.

```json
{
  "dimension_tables": ["DUMMY_TABLE"]
}
```

##### Generate `AGE` randomly

To generate the `AGE` column randomly, you must specify the column in the `generate_randomly` dictionary with the corresponding SQL expression.

```json
{
  "dimension_tables": ["DUMMY_TABLE"],
  "generate_randomly": {
    "AGE": "CAST((RAND() * (99 - 18)) + 18 AS INT64)"
  }
}
```

---

### Integration Tests

This project includes a suite of integration tests to ensure the macros and operations work correctly across different database adapters. The tests are located in the `integration_tests` directory.

#### Environment Variables

To run the integration tests, you must first create a `.env` file in the `integration_tests` directory. This file supplies the necessary environment variables for connecting to your Snowflake and Google BigQuery accounts.

**Important:** This file is not tracked by version control (git) and you will need to create it manually. The `.env` file is loaded by the devcontainer, so it must be created before launching it.

Here is the structure of the `integration_tests/.env` file:

```
DBT_SCHEMA=YourSchema

GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GCP_LOCATION=your-gcp-location
GCP_SA_KEYFILE=path/to/your/gcp_sa_key.json

SNOWFLAKE_ACCOUNT_NAME=your-snowflake-account
SNOWFLAKE_USERNAME=your-snowflake-username
SNOWFLAKE_ROLE=your-snowflake-role
SNOWFLAKE_DATABASE=your-snowflake-database
SNOWFLAKE_WAREHOUSE=your-snowflake-warehouse
SNOWFLAKE_PRIVATE_KEY_PATH=path/to/your/snowflake_rsa_key.p8
```

##### Variable Descriptions

*   `DBT_SCHEMA`: The default schema dbt will use for integration tests (dataset name in BigQuery).
*   `GOOGLE_CLOUD_PROJECT`: Your Google Cloud project ID.
*   `GCP_LOCATION`: The GCP location where your BigQuery dataset resides (e.g., `europe-west4`).
*   `GCP_SA_KEYFILE`: The path to your GCP service account key file (a `.json` file).
*   `SNOWFLAKE_ACCOUNT_NAME`: Your Snowflake account identifier.
*   `SNOWFLAKE_USERNAME`: The username for your Snowflake account.
*   `SNOWFLAKE_ROLE`: The default role to use in Snowflake.
*   `SNOWFLAKE_DATABASE`: The database to use in Snowflake.
*   `SNOWFLAKE_WAREHOUSE`: The virtual warehouse to use for running queries.
*   `SNOWFLAKE_PRIVATE_KEY_PATH`: The path to your Snowflake private key file (`.p8`) for key pair authentication.

#### Test Scripts

There are three main scripts to run the tests:

-   `run_integration_tests.sh`: This script runs the full suite of integration tests. It cleans the environment, installs dependencies, seeds data, builds the models, and then runs the `create_multiple_random_data_tables` operation.
-   `run_debug.sh`: This script is useful for debugging. It runs a smaller set of operations, including `create_multiple_random_data_tables` and `read_table`, without running all the models.
-   `run_drop_orphaned_objects_test.sh`: This script tests the `drop_orphaned_objects` macro.

#### How to run the tests

To run the integration tests, you need to be in the `integration_tests` directory.

```bash
cd integration_tests
```

Then, you can run the integration test script:

```bash
./run_integration_tests.sh
```

By default, the tests will run for both `snowflake` and `bigquery` targets. You can also specify a single target:

```bash
./run_integration_tests.sh snowflake
```

or

```bash
./run_integration_tests.sh bigquery
```

Similarly, you can run the debug script:

```bash
./run_debug.sh
```
or for a specific target:
```bash
./run_debug.sh snowflake
```

