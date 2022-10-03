# Feature selections
function excludekey!(expr::Regex,inputfeaturenames::Vector)
    deleteat!(inputfeaturenames, occursin.(expr, string.(inputfeaturenames)))
end

function excludekey!(expr::AbstractString,inputfeaturenames::Vector)
    excludekey!(Regex(expr),inputfeaturenames)
end


"""
Given feature names of the original table (before time shifted), `featureselectbyheadkey(Xtrain, featsets0)` returns the table where only variables with column name matches `headkey_set` in `featsets0` are preserved.
Noted that `headkey` in `headkey_set` must be the first keyword of the column name.

# Example
```julia
Xtrain = DataFrame(
    "tmp" => randn(10),
    "tmp_t0" => randn(10),
    "tmp_t-1" => randn(10),
    "humidity" => randn(10),
    "humidity_t0" => randn(10),
    "pressure_t0" => randn(10),
    "pressure_t1" => randn(10),
)

featsets0 = [
    [:tmp, :humidity],
    [:tmp, :pressure],
    # comma is required even when there is only one union
]
```
and

```julia-repl
julia> featureselectbyheadkey(Xtrain, featsets0)
2-element Vector{Vector{Symbol}}:
 [:tmp, :tmp_t0, Symbol("tmp_t-1"), :humidity, :humidity_t0]
 [:tmp, :tmp_t0, Symbol("tmp_t-1"), :pressure_t0, :pressure_t1]
```

"""
function featureselectbyheadkey(Xtrain, featsets0::Vector{Vector{T}}) where T <: AbstractString
    featsets = Vector{Symbol}[]
    for featset in featsets0
        push!(featsets, featureselectbyheadkey(Xtrain, featset))
    end
    return featsets
end

function featureselectbyheadkey(Xtrain, featset::Vector{<:AbstractString})
    subfeatset_tshift = Symbol[]
    for feat in featset
        targetfeats_j = names(Xtrain, Regex(join(["^",feat]))) .|> Symbol
        push!(subfeatset_tshift, targetfeats_j...)
    end
    return union(subfeatset_tshift)
end


function _featureselectbyheadkey_test(Xtrain, featsets0::Vector{Vector{T}}) where T <: AbstractString
    featsets = Vector{Symbol}[]
    for featset in featsets0
        subfeatset_tshift = Symbol[]
        for feat in featset
            targetfeats_j = names(Xtrain, Regex(join(["^",feat]))) .|> Symbol
            push!(subfeatset_tshift, targetfeats_j...)
        end
        push!(featsets, union(subfeatset_tshift))
    end
    return featsets
end
