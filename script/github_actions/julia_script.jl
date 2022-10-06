using Pkg
Pkg.add("UnicodePlots")

using UnicodePlots
lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example", name="my line", xlabel="x", ylabel="y")
println("Call a script to plot!")
