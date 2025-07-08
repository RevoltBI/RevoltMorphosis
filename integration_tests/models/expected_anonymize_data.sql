select
    {{ dbt.hash('id') }} as id,
    id as id_ORIGINAL,
    name,
    age,
    email,
    phone_number,
    sex,
    created_at,
    location,
    revenue
from {{ ref('test_table') }}