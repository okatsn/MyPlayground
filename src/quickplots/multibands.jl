"""
`quantileband!(ax, xhat::Vector{T}, ys::Vector{Vector{T}}, perc::Real, bandcolor) where T<:Real` draw a `band` of `perc` quantile to `ax`.
The band covers `perc` of data where `0 ≤ perc ≤ 1`.
"""
function quantileband!(ax, xhat::Vector{T}, ys::Vector{Vector{T}}, perc::Real, bandcolor) where T<:Real
    if !(0 ≤ perc ≤ 1)
        error("Quantile should lies between 0 and 1")
    end

    if !isequal(length(xhat), length(ys))
        error("Input x and y should be identical in length.")
    end

    cperc = 1 - perc

    qlrs = map(y -> symmquantile(y, 0.5*cperc), ys)
    bd = band!(ax, xhat, first.(qlrs), last.(qlrs); color = bandcolor, label = "$(100*perc)%")
    return bd
end

"""
`quantileband!(ax, xhat, ys, percs::Vector{<:Real}, bandcolormap::ColorSchemes.ColorScheme)`, where colors are automatically picked from `bandcolormap` according to `percs`.
It returns `(percs, bds)` where `bd = band!(...)`.

Noted that `percs` will be sorted that the order does not matter.
"""
function quantileband!(ax, xhat, ys, percs::Vector{<:Real}, bandcolormap::ColorSchemes.ColorScheme)

sort!(percs;rev=true)
bandcolors = ColorSchemes.get(bandcolormap, percs)
bds = []
    for (perc, bdcolor) in zip(percs, bandcolors)
        bd = quantileband!(ax, xhat, ys, perc, bdcolor)
        push!(bds, bd)
    end
    return (percs, bds)
end

"""
Get symmetric quantile.
E.g., `symmquantile(y, 0.15)` returns `quantile(y, [0.15, 0.85])`
"""
function symmquantile(y, qt)
    return Statistics.quantile(y, [qt, 1-qt])
end
