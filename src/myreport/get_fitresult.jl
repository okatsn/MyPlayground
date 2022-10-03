"""
Retrieve the atom model and learned parameters for each atoms
```julia
all_machs = fitted_params(mach).machines
findparam(mach::Machine{T, N}) where {T, N} = T

tps = all_machs .|> findparam # datatypes
targetmodelnamepattern = r"MLJ.*DecisionTreeRegressor"
# which matches:
# "MLJEnsembles.DeterministicEnsembleModel{DecisionTreeRegressor}"
# "MLJTuning.DeterministicTunedModel{RandomSearch, MLJEnsembles.DeterministicEnsembleModel{DecisionTreeRegressor}}"
idisforest = occursin.(targetmodelnamepattern, string.(tps))
forests_trained = all_machs[idisforest]


atomeachforest = getmodel_atom.(forests_trained)
parameachforest = getparam_atom.(forests_trained)
# [f.fitresult.fitresult.atom for f in forests_trained]

treemodels = []
treestructs = []
for (atom, treestruct) in zip(atomeachforest, parameachforest)
    push!(treestructs, treestruct)
    push!(treemodels, fill(atom, length(treestruct)))
end

learnedparams_tree = vcat(treestructs...)
atoms = vcat(treemodels...)
ntrees = length(learnedparams_tree)
# 1st model is TunedModel; 2nd is EnsembleModel
```

Also see
- [7] `build_forest(labels::AbstractVector{T}, features::AbstractMatrix{S}, n_subfeatures, n_trees, partial_sampling, max_depth, min_samples_leaf, min_samples_split) where {S, T<:Float64}` in DecisionTree at /.../DecisionTree/iWCbW/src/regression/main.jl:49
- `fit!(rf::RandomForestRegressor, X::AbstractMatrix, y::AbstractVector)` at /.../DecisionTree/iWCbW/src/scikitlearnAPI.jl:300
- `WrappedEnsemble(atom, ensemble::AbstractVector{L}) where L` at /.../MLJEnsembles/OsgHR/src/ensembles.jl
- `MMI.fitted_params(::RandomForestRegressor, forest) = (forest=forest,)` and
- `MMI.predict(::RandomForestRegressor, forest, Xnew)` at /.../MLJDecisionTreeInterface/CtTJy/src/MLJDecisionTreeInterface.jl:255
"""
function getparam_atom(obj::Machine)
    getparam_atom(obj.fitresult)
end

function getparam_atom(obj::MLJEnsembles.WrappedEnsemble)
    return obj.ensemble
end

function getmodel_atom(obj::Machine)
    getmodel_atom(obj.fitresult)
end

function getmodel_atom(obj::MLJEnsembles.WrappedEnsemble)
    return obj.atom
end
