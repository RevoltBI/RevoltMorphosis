# BigQuery Data Types

This document provides a condensed overview of GoogleSQL for BigQuery data types.

## Data Type Summary

| Type | SQL Name & Aliases | Description |
| :--- | :--- | :--- |
| **Array** | `ARRAY` | An ordered list of zero or more elements of non-array values. |
| **Boolean** | `BOOL`, `BOOLEAN` | A value that can be either `TRUE` or `FALSE`. |
| **Bytes** | `BYTES` | Variable-length binary data. |
| **Date** | `DATE` | A Gregorian calendar date, independent of time zone. |
| **Datetime** | `DATETIME` | A date and time, as on a watch, independent of time zone. |
| **Geography** | `GEOGRAPHY` | A collection of points, linestrings, and polygons on the Earth's surface. |
| **Interval** | `INTERVAL` | A duration of time, without referring to a specific point in time. |
| **JSON** | `JSON` | Represents JSON data. |
| **Integer** | `INT64`, `INT`, `SMALLINT`, `INTEGER`, `BIGINT`, `TINYINT`, `BYTEINT` | A 64-bit integer. |
| **Numeric** | `NUMERIC`, `DECIMAL` | A decimal value with 38 digits of precision and a scale of 9. |
| **BigNumeric**| `BIGNUMERIC`, `BIGDECIMAL` | A decimal value with 76.76 digits of precision and a scale of 38. |
| **Float** | `FLOAT64` | An approximate double-precision numeric value. |
| **Range** | `RANGE` | A contiguous range between two dates, datetimes, or timestamps. |
| **String** | `STRING` | Variable-length character data. |
| **Struct** | `STRUCT` | A container of ordered fields. |
| **Time** | `TIME` | A time of day, as on a clock, independent of a specific date and time zone. |
| **Timestamp** | `TIMESTAMP` | An absolute point in time, independent of any time zone. |

---

## Data Type Properties

### Orderable
Can be used in an `ORDER BY` clause.
- **Supported:** All types except `ARRAY`, `STRUCT`, `GEOGRAPHY`, `JSON`.
- **`NULL`s:** Sorted as the minimum possible value (`NULLS FIRST` in `ASC`, `NULLS LAST` in `DESC`).
- **Floating Points:** Sorted as `NULL`, `NaN`, `-inf`, negative numbers, 0, positive numbers, `+inf`.

### Groupable
Can be used in `GROUP BY`, `DISTINCT`, and `PARTITION BY` clauses.
- **Supported:** All types except `GEOGRAPHY`, `JSON`.
- **Note:** Floating point types are not supported in `PARTITION BY`.

### Comparable
Can be compared to each other.
- **Supported:** All types except `GEOGRAPHY`, `JSON`, `ARRAY`.
- **Structs:** Equality (`=`, `!=`, `IN`) is supported field-by-field. Less/greater than is not.

### Collatable
Supports collation for sorting and comparing strings.
- **Supported:** `STRING`, string fields in a `STRUCT`, string elements in an `ARRAY`.

---

## Parameterized Data Types
You can specify constraints for `STRING`, `BYTES`, `NUMERIC`, and `BIGNUMERIC` types.

**Syntax:** `DATA_TYPE(param1, ...)`

**Example:**
```sql
-- A string with a maximum length of 10 characters
DECLARE x STRING(10);

-- A numeric type with precision 5 and scale 2
DECLARE y NUMERIC(5, 2);
```
Constraints are enforced on write. Type parameters are not propagated in expressions.

---

## Data Type Reference

### `ARRAY`
- **Definition:** An ordered list of elements of the same non-array type.
- **Declaration:** `ARRAY<T>`
- **Construction:** `[element1, element2, ...]` or `ARRAY<T>[...]`
- **Note:** Arrays of arrays are not allowed. Use a `STRUCT` wrapper: `ARRAY<STRUCT<ARRAY<T>>>`. `NULL` arrays are distinct from empty arrays within a query but are written as empty arrays to a table.

### `BOOL`
- **Definition:** A value that is `TRUE` or `FALSE`.
- **Literals:** `TRUE`, `FALSE`

### `BYTES`
- **Definition:** Variable-length binary data.
- **Literals:** `b"..."` or `b'...'`
- **Parameterized:** `BYTES(L)` for a maximum length `L`.

### `DATE`
- **Definition:** A Gregorian calendar date.
- **Range:** `0001-01-01` to `9999-12-31`
- **Canonical Format:** `YYYY-MM-DD`

### `DATETIME`
- **Definition:** A Gregorian date and time.
- **Range:** `0001-01-01 00:00:00` to `9999-12-31 23:59:59.999999`
- **Canonical Format:** `YYYY-MM-DD { |T}HH:MM:SS[.F]`

### `GEOGRAPHY`
- **Definition:** A collection of points, linestrings, and polygons on the WGS84 ellipsoid.
- **Subtypes:** `Point`, `LineString`, `Polygon`, `MultiPoint`, `MultiLineString`, `MultiPolygon`, `GeometryCollection`.

### `INTERVAL`
- **Definition:** A duration of time.
- **Canonical Format:** `[sign]Y-M [sign]D [sign]H:M:S[.F]`
- **Construction:** `INTERVAL int_expression datetime_part` (e.g., `INTERVAL 5 DAY`)

### `JSON`
- **Definition:** Represents JSON data.
- **Note:** Whitespace is not preserved. Object member order is not guaranteed. Duplicate keys are resolved to the first key found.

### Numeric Types
- **`INT64`:** 64-bit integer.
- **`NUMERIC`:** Fixed-point decimal with precision 38 and scale 9.
- **`BIGNUMERIC`:** Fixed-point decimal with precision 76.76 and scale 38.
- **`FLOAT64`:** Double-precision approximate numeric values. Handles `NaN` and `+/-inf`.

### `RANGE`
- **Definition:** A contiguous range. The lower bound is inclusive, the upper bound is exclusive.
- **Declaration:** `RANGE<T>` where `T` is `DATE`, `DATETIME`, or `TIMESTAMP`.
- **Construction:** `RANGE<T> '[lower_bound, upper_bound)'`

### `STRING`
- **Definition:** Variable-length Unicode character data (must be UTF-8 encoded).
- **Literals:** `"..."` or `'...'`
- **Parameterized:** `STRING(L)` for a maximum length `L`.

### `STRUCT`
- **Definition:** A container of ordered fields.
- **Declaration:** `STRUCT<[field_name] field_type, ...>`
- **Construction:** `STRUCT(expr1 AS field1, ...)`

### `TIME`
- **Definition:** A time of day.
- **Range:** `00:00:00` to `23:59:59.999999`
- **Canonical Format:** `HH:MM:SS[.F]`

### `TIMESTAMP`
- **Definition:** An absolute point in time with microsecond precision, stored as a UTC offset.
- **Range:** `0001-01-01 00:00:00` to `9999-12-31 23:59:59.999999` UTC
- **Canonical Format:** `YYYY-MM-DD HH:MM:SS[.F] [time_zone]`
- **Time Zones:** Can be specified by UTC offset (e.g., `-08:00`) or by name (e.g., `America/Los_Angeles`). If omitted, UTC is the default.

---

## Data Type Sizes

| Data type | Size in Logical Bytes |
| :--- | :--- |
| `ARRAY` | Sum of the size of its elements. |
| `BIGNUMERIC` | 32 |
| `BOOL` | 1 |
| `BYTES` | 2 + number of bytes in the value |
| `DATE` | 8 |
| `DATETIME` | 8 |
| `FLOAT64` | 8 |
| `GEOGRAPHY` | 16 + (24 * number of vertices) |
| `INT64` | 8 |
| `INTERVAL` | 16 |
| `JSON` | Size of the canonical UTF-8 string representation. |
| `NUMERIC` | 16 |
| `RANGE` | 16 |
| `STRING` | 2 + UTF-8 encoded string size |
| `STRUCT` | 0 + size of contained fields |
| `TIME` | 8 |
| `TIMESTAMP` | 8 |

**Note:** A `NULL` value for any data type has a size of 0 logical bytes.
