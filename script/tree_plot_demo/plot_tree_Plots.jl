using MLJ
using DataFrames
using MLJDecisionTreeInterface
using DecisionTree
using Plots

using SWCForecast

thisdir(args...) = projectdir("script","tree_plot_demo", args...)# SETME

mach = machine(thisdir("test_machine_onetree.jlso"))
tree = mach.fitresult.fitresult
var_names = names(mach.fitresult.data[1]) # column names of the input table; the order does matter.
# plot the entire tree
p = plot(tree, var_names)
# display(p)  # If the depth is too deep, vscode cannot display the image
# savefig(p, thisdir("0x4d78db3fe0180495.png"))

# plot to depth 2
p = plot(tree, var_names, 2)


# print tree
tree_structure(mach, DescriptOneTree(thisdir), thisdir("tree.txt"))

# plot the left branch of the left branch
p = plot(tree.left.left, var_names)

mach2 = machine(thisdir("test_machine_comptree.jlso"))
tree2 = fitted_params(mach2).best_fitted_params.model.tree
var_names = fitted_params(mach2).best_fitted_params.selector.features_to_keep
# plot the entire tree
p = plot(tree2, var_names)
# display(p)  # If the depth is too deep, vscode cannot display the image
# savefig(p, thisdir("0x4d78db3fe0180495.png"))
