# Private Macro Naming Convention

## Rule

All "private" macros must be prefixed with a double underscore (`__`). A private macro is an internal helper macro that is not intended for direct use by the end-user of the package.

This convention applies to both the `.sql` filename and the macro name defined within the file.

## Rationale

This convention clearly distinguishes internal-only macros from the public API of the package. It prevents users from accidentally relying on helper macros that might change without notice, and it makes the project's internal structure easier to understand for contributors.

## Example

A private macro for converting string cases should be implemented as follows:

**Filename:** `macros/__convert_string.sql`

```sql
{% macro __convert_string(string, mode) %}
    ...
{% endmacro %}
```
