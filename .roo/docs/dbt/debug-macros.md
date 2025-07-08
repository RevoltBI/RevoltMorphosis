# dbt Debugging and Output Macros

When creating helper macros for debugging and inspecting data, especially for `dbt run-operation` calls, follow these best practices to ensure flexible and clean output.

## 1. Use `print()` for Console Output in Operations

When a `dbt run-operation` needs to output a result directly to the console (like a raw CSV), use the `print()` Jinja function. The standard `return()` function will not print the value to `stdout` during a `run-operation` call, making it invisible to the user and preventing output redirection.

## 2. Suppress dbt Logs with `--quiet` for Clean Output

To get a clean output from a macro that can be redirected to a file (e.g., `> my_output.csv`), use the `--quiet` (or `-q`) global flag with your `dbt run-operation` command. This flag suppresses all of dbt's own informational logging but preserves any output from the `print()` function.

**Command for clean output:**
```bash
dbt --quiet run-operation my_operation > my_output.csv
```

## 3. Handle `stdout` vs. `stderr`

Be aware that the `--quiet` flag only suppresses logs sent to standard output (`stdout`). Warnings from underlying Python libraries (e.g., `UserWarning` from the Snowflake connector) are often sent to standard error (`stderr`). This is the desired behavior, as these warnings will appear in the console but will **not** be captured when redirecting `stdout` to a file.
