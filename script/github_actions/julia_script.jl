using Pkg

using UnicodePlots
lnp = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example", name="my line", xlabel="x", ylabel="y")
println(lnp)
println("⬆️⬆️⬆️ If you see the plot then it works!")
