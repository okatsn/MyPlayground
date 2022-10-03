# todo: plot tree with Makie.jl
# please refer to this thread: https://github.com/JuliaAI/DecisionTree.jl/issues/147
using MLJ
using DataFrames
using MLJDecisionTreeInterface
using DecisionTree
using CairoMakie

using SWCForecast


using Random
X, y = make_blobs(300;rng=MersenneTwister(1234))

dtc = @load DecisionTreeClassifier pkg=DecisionTree verbosity=0
dtc_model = dtc(min_purity_increase=0.005, min_samples_leaf=1, min_samples_split=2, max_depth=3)
dtc_mach = machine(dtc_model, X, y)
MLJ.fit!(dtc_mach)
x = fitted_params(dtc_mach)
#print_tree(x.tree)

f = Figure(;resolution=(1000, 800))
ax1 = Axis(f[1,1])
drawTree(x.tree, x.encoding, ax1; feature_names=["X1", "X2"],
        nodetextsize=20, nodetextcolor=:black, nodewth=12,
        linetextsize=13, leaftextsize=13, leafwth=4)
hidespines!(ax1)
hidedecorations!(ax1)
f
