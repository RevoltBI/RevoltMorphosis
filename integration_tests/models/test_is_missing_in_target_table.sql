-- Purpose: Create a dataset that is missing a record from the source seed.
SELECT *
FROM {{ ref('test_table') }}
WHERE id != 2