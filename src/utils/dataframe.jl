"""
    narrow_types!(df)

Narrows the `eltype` of each column to the type that actually exists in the each column of
dataframe.

# Arguments
- `df`: Dataframe for which you want to narrow the `eltype` of each column

# References
https://discourse.julialang.org/t/how-to-change-field-names-and-types-of-a-dataframe/43991/9
"""
function narrow_types!(df)
    for column_name in names(df)
        df[!, column_name] = identity.(df[!, column_name])
    end
    return df
end

"""
    convert_types(df, column_names_types)

Converts the element type of each column to a user-specified type.

# Arguments
- `df`: Dataframe for which you want to convert the `eltype` of each column
- `column_names_types`: Column names and target types. The type of `column_names_types`
    should be able to be unpacked into column names and target types in a for loop.

# References
https://discourse.julialang.org/t/how-to-change-field-names-and-types-of-a-dataframe/43991/11
"""
function convert_types(df, column_names_types)
    for (column_name, column_type) in column_names_types
        df[!, column_name] = convert.(column_type, df[!, column_name])
    end
    return df
end
