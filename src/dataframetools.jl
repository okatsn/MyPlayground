# small tools concerning DataFrame
# using DataFrames, Dates
function SWCForecast.isnan(x::AbstractString)
    if in(x, ["#VALUE!", "nan", "NaN", "Nan"])
        return true
    else
        return false
    end
end

function SWCForecast.isnan(x::DateTime)
    return false
end

# Drop missing, nothing and nan (deprecated):
# df_input = filter(row -> !any(f -> any(f.([r for r in row])), (ismissing, isnothing, isnan)), df_all[!,featkeys])
# See: https://stackoverflow.com/questions/62789334/how-to-remove-drop-rows-of-nothing-and-nan-in-julia-dataframe

"""
Given either `missing`, `NaN` and `Number`, returns "Missing", "Not a Number" and "Number".
"""
function describeinstr(x)
    if ismissing(x)
        return "Missing"
    else
        if isnan(x)
            return "Not a Number"
        else
            return "Number"
        end
    end
end

ignoring = "ignoring `NaN` and `missing`"

"""
`ifstrparse(x, TYPE)`: if `x` is `AbstractString`, then parse it to the variable of `TYPE`, $ignoring.
"""
function ifstrparse(x, TYPE)
    if !ismissing(x) && !isnan(x) && isa(x, AbstractString)
        return parse(TYPE, x)
    else
        return x
    end
end

"""
`checkparse(df::DataFrame, TYPE)` check if all elements column variables can be parsed to a specific data `TYPE`. It returns a dictionary with the column names of `df` as its keys, and a vector of DataType and anything that cannot be parsed to `TYPE`.
"""
function checkparse(df::DataFrame, TYPE)
    pc = pe = Dict()
    for k in names(df)
        subdf =
            select(
                df, k => ByRow(x -> isableparse(x, TYPE)) => x -> x * "_can_be_parsed_to"
            ) |> unique
        vc = (contains=Any[subdf[!, 1]...],)
        # ve = (eltype=eltype(df[!,k]), )
        push!(pc, k => vc)
        # push!(pe, k => ve)
    end
    return pc
end

"""
`isableparse(x, TYPE)` use `try...catch` to check if `x` can be parsed to of `TYPE`. If not, return `x`; else, return `TYPE`. If `x::TYPE` it also returns `TYPE` evenif it can't be parsed to the type of itself.
"""
function isableparse(x, TYPE)
    try
        if !isa(x, TYPE)
            parse(TYPE, x)
        end
        return TYPE
    catch
        return x
    end
end

"""
`convertdf2!(df, TYPE)` convert all elements in `df` to the type of `TYPE`, $ignoring.
"""
function convertdf2!(df, TYPE)
    return df .= ifstrparse.(df, TYPE)
end

"""
`reducetype(v::AbstractArray)` returns the array of type `Union{uniqueTYPE}`, where `uniqueTYPE = v .|> typeof |> unique`.

For more about manipulating datatype, also see `nonmissingtype` in [missing.jl](https://github.com/JuliaLang/julia/blob/master/base/missing.jl) and `Base.typesplit` in [promotion.jl](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl)
"""
function reducetype(v::AbstractArray)
    uniqueTYPE = v .|> typeof |> unique
    if Union{uniqueTYPE...} == eltype(v)
        # do nothing
    else
        v = convert(AbstractArray{Union{uniqueTYPE...}}, v)
    end
    return v
end

function reducetype!(df::DataFrame)
    return select!(df, All() .=> x -> reducetype(x); renamecols=false)
end

function allownewtype(v::AbstractArray, newtype::DataType) end


"""
`selectnames(dfnames, args...)` select an array of names that contains `arg::String` or pattern that matches `arg::Regex`.

# Example
```julia
julia> selectnames(["Soil_water_content_10cm, water_level_#1, water_level_#2"], r"water_lev")

[water_level_#1, water_level_#2"]
```

"""
function selectnames(dfnames, args...)
strvec = []
for arg in args
    vec = selectname(dfnames, arg)
    push!(strvec, vec)
end

return union(strvec...)
end

function selectnames(df::DataFrame, args...)
    dfnames = names(df)
    return selectnames(dfnames, args...)
end

function selectname(dfnames::Vector{<:AbstractString}, arg)
    return dfnames[contains.(dfnames, arg)]
end

function selectname(dfnames::Vector{<:AbstractString}, arg::InvertedIndex)
    return dfnames[.!contains.(dfnames, arg.skip)]
end

"""
`selectname(df::DataFrame, arg)` returns a vector of column names that match `arg` of the dataframe `df`. `arg` can be `Regex`, `AbstractString`, or `InvertedIndex`.
"""
function selectname(df::DataFrame, arg)
    dfnames = names(df)
    return selectname(dfnames, arg)
end


"""
`get1var(df::DataFrame, expr::Regex)` indexes `df` on the only one column that matches `expr`.
If more than one columns are matched, it raises an error.
"""
function get1var(df::DataFrame, expr::Union{Regex, InvertedIndex})
    df2 = df[!, expr]
    if ncol(df2) != 1
        error("Zero or multiple columns matched.")
    end
    return only(eachcol(df2)) # df2[!,only(names(df2))]
end

"""
`get1var(df::DataFrame)` returns the only one column of `df` as a `Vector`.
If there are more than one column, it raises an error.
"""
function get1var(df::DataFrame)
    if ncol(df) != 1
        error("Zero or multiple columns matched.")
    end

    return only(eachcol(df))
end

"""
`get1var(v::Vector)` get the only variable in the vector `v` which should have exactly one element; an error will be raised if `length(v) != 1`.
"""
function get1var(v::Vector)
    if length(v) != 1
        error("Zero or multiple elements in the vector.")
    end
    return first(v)
end


"""
`dropmissingcol(df)` drops columns which are all missing.
"""
function dropmissingcol(df)
    return df[!, all.(!ismissing, eachcol(df))]
end




"""
`chknnm(df)` check if DataFrame `df` contains missing values or NaN.
    Use this before input `df` into machine.
"""
function chknnm(df)
    ddf = describe(df)
    if sum(ddf.nmissing) > 0
        error("There are still missing value(s) in the DataFrame.")
    end

    if any(isnan.(ddf.mean))
        error("Data contains NaN; which might cause crash in model training.")
    end
end
