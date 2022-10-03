"""
    load_decision_tree_regressor(; package="DecisionTree", kwargs...)

A wrapper function for `MLJ` @load macro that returns a `DecisionTreeRegressor` object.

# Keywords
- `package::AbstractString="DecisionTree"`: Package that provides `DecisionTreeRegressor`,
    which now has ["DecisionTree", "BetaML"] to choose from
- `kwargs`: Valid hyperparameters of `DecisionTreeRegressor`
"""
function load_decision_tree_regressor(; package::AbstractString="DecisionTree", kwargs...)
    # 1. take type out 2. then we are able to construct
    tree_type = @eval @load "DecisionTreeRegressor" pkg = $(Meta.parse(package)) verbosity =
        0
    tree_model = tree_type(; kwargs...)
    return tree_model
end
# this is mostly for memorizing how to load and use DecisionTree
