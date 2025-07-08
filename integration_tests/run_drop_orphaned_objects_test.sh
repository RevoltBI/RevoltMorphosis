#!/usr/bin/env bash

set -e

if [ -n "$1" ]; then
    targets="$1"
else
    targets="snowflake bigquery"
fi

for target in $targets; do
    echo "Running drop_orphaned_objects test for target: $target"
    dbt clean --target "$target"
    dbt deps --target "$target"
    dbt seed --full-refresh --target "$target"
    dbt run-operation RevoltMorphosis.create_multiple_random_data_tables --target "$target" --args "$(cat ${target}_create_multiple_random_data_tables_args.json)"
    dbt run-operation RevoltMorphosis.drop_orphaned_objects --target "$target" --args "$(cat drop_orphaned_objects_args.json)"
    dbt run-operation RevoltMorphosis_integration_tests.verify_drop_orphaned_objects --target "$target"
done
