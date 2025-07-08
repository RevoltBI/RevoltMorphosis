# dbt Macro Calling Convention

## Golden Rule: Always Prefix Macro Calls

To ensure robust and predictable macro resolution, all macro calls **must** be explicitly prefixed with their parent package name. This applies to calls within Jinja (`{{ ... }}`) and to `dbt run-operation` commands from the command line.

This is critical because this package is designed to be used as a dependency, and dbt requires prefixes to find macros in other packages.

### 1. Jinja Calls (e.g., in models, macros)

When calling a macro that is part of this (`RevoltMorphosis`) package, always use the `RevoltMorphosis` prefix.

**Correct:**
```jinja
{{ RevoltMorphosis.my_internal_macro() }}
```

When calling macros from other dbt packages (e.g., `dbt_utils`), use their respective package name as a prefix.

**Correct:**
```jinja
{{ dbt_utils.generate_surrogate_key(...) }}
```

### 2. Command Line Calls (`dbt run-operation`)

When executing a macro via `dbt run-operation`, the macro name must be prefixed with its package name.

**Correct:**
```bash
dbt run-operation RevoltMorphosis.my_macro --args '{...}'
```

**Incorrect:**
```bash
dbt run-operation my_macro --args '{...}'
```

### 3. Integration Test Calls

For clarity and consistency, any macros defined within the `integration_tests` project should also be prefixed, both in Jinja and in `run-operation` calls.

**Correct `run-operation`:**
```bash
dbt run-operation RevoltMorphosis_integration_tests.verify_drop_orphaned_objects
```

**Correct Jinja:**
```jinja
{{ RevoltMorphosis_integration_tests.my_test_helper_macro() }}
```

### 4. Exception: The Dispatch Mechanism

There is one specific exception to this rule. When a macro has been called via `adapter.dispatch`, any subsequent calls *from within that dispatched macro* to *other dispatched macros* (like `randomdata` or `randomfact`) do not require a prefix. dbt's dispatch mechanism handles this resolution automatically based on the configured search path.

**Context:** `macros/generate_data/bigquery__create_random_data_table.sql`
```jinja
-- This is correct because both macros are resolved by the dispatch mechanism
{{ randomdata(...) }}
```
