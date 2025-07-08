# Modifying Macros with Integration Tests

When Modifying a dbt macro that is covered by integration tests, it is crucial to follow a comprehensive approach to ensure that the tests remain valid and effective.

## Key Steps

1.  **Update Macro Signature and Logic**: Make the necessary changes to the macro's signature and internal logic.
2.  **Update Test Arguments**: If the macro is called from a test script with arguments (e.g., from a JSON file), update the argument files to match the new macro signature and logic.
3.  **Use Adapter-Specific Arguments (If Needed)**: When testing cross-database macros, if the SQL syntax for arguments differs between adapters, use separate, adapter-specific argument files.
4.  **Update Test Scripts**: Modify the test scripts (e.g., `run_integration_tests.sh`, `run_debug.sh`) to use the new argument files and to correctly call the modified macro.
5.  **Run Tests**: Execute the integration tests for all supported database adapters to verify that the Modifying was successful and did not introduce any regressions.
