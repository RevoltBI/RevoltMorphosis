# dbt Integration Test Execution

When running integration tests for this dbt package, all test scripts, including `run_integration_tests.sh` and `run_debug.sh`, must be executed from within the `integration_tests/` directory.

This is necessary because the dbt commands within the scripts rely on finding the `profiles.yml` file in the current working directory. Running the scripts from the root of the project will cause dbt to look for the profiles in the default location (`~/.dbt/`), which will result in an error.

**Correct Usage:**
```bash
cd integration_tests/
./run_integration_tests.sh
```

Or just run the script directly in the `integration_tests` directory.

**Incorrect Usage:**
```bash
./integration_tests/run_integration_tests.sh
```
