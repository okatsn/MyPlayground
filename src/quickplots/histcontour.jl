
"""
`forcontourf(allx::Vector, ally::Vector, xedges, yedges)` returns `xs, ys, zs` for `CairoMakie.contourf!(xs, ys, zs)`.

Noted that `length(xs) + 1` = `length(xedges)`.

# Input argument

- `allx`, `ally` are each a vector of values corrsponding to the X and Y coordinates in the plot, indicating all points on the X-Y plane.
- `xedges`, `yedges` are each a range specifying the edges for calculating 2D histogram.


"""
function forcontourf(allx::Vector, ally::Vector, xedges, yedges)
    h = FHist.Hist2D((allx, ally), (xedges, yedges))
    counts2d = FHist.bincounts(h) # a m × n Matrix where m = length(xedges) - 1
    lenxs, lenys = size(counts2d)

    # # You can get bincenters by:
    # xs0, ys0 = map(collect, FHist.bincenters(h))

    # # This is OK but superfluous
    # xs = [(xs0' .* ones(leny))...]
    # ys = [(ones(lenx)' .* ys0)...]
    # zs = [counts2d'...]
    xmin, xmax = extrema(xedges)
    ymin, ymax = extrema(yedges)

    xs = LinRange(xmin, xmax, lenxs)
    ys = LinRange(ymin, ymax, lenys)
    zs = counts2d

    return xs, ys, zs

end

function forcontourf(points, xedges, yedges)
    allx = first.(points)
    ally = last.(points) # or alternatively [y for pts in predpoints0 for (x, y) in pts]
    return forcontourf(allx, ally, xedges, yedges)
end
