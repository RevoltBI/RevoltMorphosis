#!/usr/bin/env bash

set -e

if [ -n "$1" ]; then
    targets="$1"
else
    targets="snowflake bigquery"
fi

for target in $targets; do
    echo "Running debug for target: $target"
    dbt clean --target "$target" && \
    dbt deps --target "$target" && \
    dbt seed --target "$target" --full-refresh && \
    dbt run-operation RevoltMorphosis.create_multiple_random_data_tables --target "$target" --args "$(cat ${target}_create_multiple_random_data_tables_args.json)" && \
    dbt run-operation RevoltMorphosis.inspect_relation --target "$target" --args '{"relation_name": "MOCK_test_table"}'
done