#!/bin/bash
set -e

if [ -n "$1" ]; then
    targets="$1"
else
    targets="snowflake bigquery"
fi

for target in $targets; do
    echo "Running transient models test for target: $target"
    dbt clean --target "$target"
    dbt deps --target "$target"
    # build the models
    dbt build --select test_transient_model test_permanent_model --target "$target"

    # verify the results
    dbt run-operation RevoltMorphosis_integration_tests.verify_drop_transient_models --target "$target"
done
