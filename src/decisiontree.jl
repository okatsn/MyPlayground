# ================ Common Functions and Structures ====================
abstract type AbstractDescription end

abstract type DescriptDecisionTree <: AbstractDescription end

# ================ DecisionTree's Exclusive Functions and Structures ====================

# ONE TREE
mutable struct DescriptOneTree <: DescriptDecisionTree
# mutable struct DescriptOneTree5
    description_dir::Function
    description::Dict
end
# DescriptOneTree = DescriptOneTree5

function DescriptOneTree(description_dir::Function)
# function DescriptOneTree5(description_dir::Function)
    DescriptOneTree(description_dir, Dict{String, Any}())
end

function SWCForecast.show(io::IO, DDT::DescriptOneTree)
    println(io, "Script path: $(DDT.description_dir())")
    println(io, "Content: $(DDT.description)")
end

# COMPOSING ONE TREE WITH FeatureSelector
mutable struct DescriptCompTree <: DescriptDecisionTree
    description_dir::Function
    description::Dict
    model
    ranges::Vector
end

function DescriptCompTree(description_dir::Function)
    DescriptCompTree(description_dir, Dict{String, Any}(), nothing, [])
end

function SWCForecast.show(io::IO, DDT::DescriptCompTree)
    println(io, "Script path: $(DDT.description_dir())")
    println(io, "Content: $(DDT.description)")
    println(io, "Model: $(DDT.model)")
    println(io, "Ranges: $(DDT.ranges)")

end


# COMPOSING ONE FOREST WITH FeatureSelector
mutable struct DescriptOneForest <: DescriptDecisionTree
    description_dir::Function
    description::Dict
    model
    ranges::Vector
end

function DescriptOneForest(description_dir::Function)
    DescriptOneForest(description_dir, Dict{String, Any}(), nothing, [])
end

function SWCForecast.show(io::IO, DDT::DescriptOneForest)
    println(io, "Script path: $(DDT.description_dir())")
    println(io, "Content: $(DDT.description)")
    println(io, "Model: $(DDT.model)")
    println(io, "Ranges: $(DDT.ranges)")
end



# EnsembleModel
mutable struct DescriptEnsembleTrees <: DescriptDecisionTree
    description_dir::Function
    description::Dict
    model
    ranges::Vector
end

function DescriptEnsembleTrees(description_dir::Function)
    DescriptEnsembleTrees(description_dir, Dict{String, Any}(), nothing, [])
end

function SWCForecast.show(io::IO, DDT::DescriptEnsembleTrees)
    println(io, "Script path: $(DDT.description_dir())")
    println(io, "Content: $(DDT.description)")
    println(io, "Model: $(DDT.model)")
    println(io, "Ranges: $(DDT.ranges)")
end




## Export tree_structure.txt
# https://discourse.julialang.org/t/redirect-stdout-and-stderr/13424/5
"""
# Consider deprecate this function
"""
function tree_structure(mach, DDT::DescriptOneTree, path)
open(path, "w+") do io # e.g., path = exp_resultdir("tree_structure.txt")
    println(io, "===== Tree Summary =====")
    println(io, mach.fitresult.fitresult)
    println(io, "===== Tree Structure =====")
    redirect_stdout(io) do
        MLJDecisionTreeInterface.DT.print_tree(
            mach.fitresult.fitresult; feature_names=names(mach.fitresult.data[1])
        )
    end
end
end

"""
Given the machine `mach`, print the structure of tree to the output variable `tree_info::string` using `MLJDecisionTreeInterface.DT.print_tree`.

# Example
```julia
tree_info = tree_structure(mach)
```

# Consider deprecate this function
"""
function tree_structure(mach, DDT::DescriptOneTree)
    printfun() = MLJDecisionTreeInterface.DT.print_tree(
        mach.fitresult.fitresult; feature_names=names(mach.fitresult.data[1]));
    tree_info = print2string(printfun)
    return tree_info
end


function tree_structure(mach::Machine, DDT::DescriptCompTree,  path::AbstractString)
    feat_bestmodel = fitted_params(mach).best_fitted_params.selector.features_to_keep

    tree = fitted_params(mach).best_fitted_params.model.tree
    open(path, "w+") do io # e.g., path = exp_resultdir("tree_structure.txt")
    println(io, "===== Tree Summary =====")
    println(io, tree)
    println(io, "===== Tree Structure =====")
    redirect_stdout(io) do
        MLJDecisionTreeInterface.DT.print_tree(
            tree; feature_names=string.(feat_bestmodel)
        )
    end
end
end


"""
# WARNING
Your pipeline must have the field `selector = FeatureSelector()`, e.g.,
```julia

mypipe = Pipeline(
    selector = FeatureSelector(),
    model = model
)

tuned_model = TunedModel(;
    model=mypipe)

mach = machine(
    tuned_model,
    X, # a dataframe
    y, # a vector
)

mach_report = report(mach)
```

"""
function tree_structure(mach::Machine, DDT::DescriptCompTree)
    feat_bestmodel = fitted_params(mach).best_fitted_params.selector.features_to_keep
    # or:
    # mach_report = report(mach);
    # feat_bestmodel = mach_report.best_model.selector.features

    tree = fitted_params(mach).best_fitted_params.model.tree

    printfun() = MLJDecisionTreeInterface.DT.print_tree(
        tree; feature_names=string.(feat_bestmodel));
    tree_info = print2string(printfun)
    return tree_info
end

"""
Given a vector of machines, `findtrees(machs::Vector{Machine})` returns a vector of only `Machine{DecisionTreeRegressor, ...}`.
"""
function findtrees(machs::Vector{Machine})

end








"""
`FeatureCounts` of:
    maxlevel: the max level of nodes to inspect
    featids: the obtained identity number for features at nodes
    featvals: the obtained values of thresholds at nodes
    atlevels: the current level

# Example
```julia
FC = FeatureCounts(4)
treeinspect!(FC, WEE1) # WEE1 is the DecisionTree.Root object
```

# See also
- treeinspect!
"""
mutable struct FeatureCounts
    maxlevel
    featids
    featvals
    atlevels
end

function FeatureCounts(maxlevel)
    FeatureCounts(maxlevel,[],[],[])
end

"""
`treeinspect!(FC::FeatureCounts, WEE1::DecisionTree.Root)` recursively obtain the feature names and splitting thresholds of the tree nodes. Also see `FeatureCounts`.

# Example
First, obtain the `DecisionTree.Root` object from the trained machine containing model of decision tree.
```julia
ftpr = fitted_params(mach1)
transformers = [v for (k, v) in ftpr.fitted_params_given_machine]
featnames = transformers[1].features_to_keep .|> string
WE = transformers[2].fitresult # WrappedEnsemble
WEE1 = WE.ensemble[1]
```
> **WARNING**: how the `DecisionTree.Root` object `WEE1` depends on the structure of your composite model.

Second, put the `DecisionTree.Root` object into `treeinspect!`

```julia
FC = FeatureCounts(4) # to at most 4th level
treeinspect!(FC, WEE1)
```

In final (optional), output the table
```julia-repl
julia> DataFrame(FC; feature_names=featnames)
13×3 DataFrame
 Row │ feature                  value    level
     │ Any                      Any      Any
─────┼─────────────────────────────────────────
   1 │ precipitation_1d_t0      79.3     1
   2 │ precipitation_3d_t-2     4.9      2
   3 │ precipitation_12hr_t0    47.25    2
   4 │ humidity_CWB_t-6         81.5009  3
   5 │ precipitation_1d_t0      7.75     3
   6 │ humidity_CWB_t-24        94.2036  3
   7 │ precipitation_1hr_t-2    2.0      3
   8 │ precipitation_3d_t-24    0.65     4
   9 │ air_temperature_t-4      13.703   4
  10 │ precipitation_1d_t-18    1.4      4
  11 │ precipitation_12hr_t0    20.25    4
  12 │ precipitation_12hr_t-12  49.5     4
  13 │ precipitation_1hr_t0     2.0      4
```


"""
function treeinspect!(FC::FeatureCounts, WEE1::DecisionTree.Root; only_at=nothing)
    lv = FC.maxlevel
    treeinspect!(FC, WEE1.node, lv, only_at)
end

function treeinspect!(FC::FeatureCounts, WEE1::DecisionTree.Leaf, lv, only_at)
    return nothing
end

function SWCForecast.DataFrame(FC::FeatureCounts; column_names= [:feature,:value,:level], feature_names=nothing)
    if isnothing(feature_names)
        feature = FC.featids
    else
        feature = feature_names[FC.featids]
    end
    df = DataFrame([feature, FC.featvals, FC.atlevels], column_names)
    sort!(df, last(column_names))
end

function treeinspect!(FC::FeatureCounts, WEE1::DecisionTree.Node, lv, only_at)
    thislevel = FC.maxlevel-lv +1
    if isnothing(only_at) || (thislevel == only_at)
        push!(FC.featids, WEE1.featid)
        push!(FC.featvals, WEE1.featval)
        push!(FC.atlevels, thislevel)
    end

    lv = lv - 1
    if lv <= 0
        return nothing
    end
    treeinspect!(FC, WEE1.left , lv, only_at)
    treeinspect!(FC, WEE1.right, lv, only_at)
end
