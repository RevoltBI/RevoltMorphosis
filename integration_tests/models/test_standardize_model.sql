
{{ RevoltMorphosis.standardize_model(
    relation=ref('test_table'),
    exclude_columns=['age'],
    columns_mode='upper',
    empty_to_null=true,
    surrogate_key_columns=['ID', 'Name', 'AGE', 'email', 'PHONE_NUMBER', 'SEX'],
    surrogate_key_delimiter='/',
    hash_surrogate_key=false
) }}