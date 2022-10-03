"""
`datetimeticks!(ax2, t::Vector{DateTime}, x::Vector; datestrformat = "yyyy/mm/dd")` set x ticks to datestr format. `t` is the `DateTime` array that is not supported by Makie, `x` is a arbitrarily defined series of numbers that corresponds to `t` for `Makie.plot`. `x` and `t` must be the same length and should be pairwisely mapped.

# Example:
```julia
t = df.datetime
x = Dates.datetime2epochms.(t)
x1 = x .- x[1] # to avoid glitchs in plotting with CairoMakie (due to the too-large values)
y = df.soil_water
CairoMakie.scatter!(ax, x, y, markersize =3)
datetimeticks!(ax2, t,x)

```

"""
function datetimeticks!(ax2, t::Vector{DateTime}, x_a::Vector; datestrformat = "yyyy/mm/dd")
    t0, t1, t10, x0, x1, x10 = _datetimetick0(t, x_a)

    dateticks = optimize_ticks(extrema(t)...)[1]
    # PlotUtils.optimize_ticks(t0::DateTime, t1::DateTime) don't apply kwargs such as `k_min` and `k_max` in the function even when the kwarg is supported. See the source code.
    xticks, xticklabels = ticklabelconvert(t0, t1, t10, x0, x1, x10, dateticks, datestrformat)

    ax2.xticks[] = (xticks, xticklabels)
    return xticks, xticklabels
end

"""
Similar to `datetimeticks!(ax2, t::Vector{DateTime}, x_a::Vector)`, `datetimeticks!(ax2, t::Vector{DateTime}, x_a::Vector, tinc::DatePeriod; datestrformat = "yyyy/mm/dd", modify_fn = identity)` return `xticks, xticklabels` with `xticks` forced to increase with step `tinc`, and be modify by function `modify_fn`.

# Example
```julia
datetimeticks!(
    ax2,
    [DateTime(2012,2,5,3,15,0), DateTime(2012,3,5,3,15,0)],
    [0, 1], # `x` for `Makie.plot(x, ...)`
    Day(3); # tick every 3 days
    datestrformat = "yyyy/mm/dd",
    modify_fn = x -> floor.(x, Day)
)

```

"""
function datetimeticks!(ax2, t::Vector{DateTime}, x_a::Vector, tinc::DatePeriod; datestrformat = "yyyy/mm/dd", modify_fn = identity)
    t0, t1, t10, x0, x1, x10 = _datetimetick0(t, x_a)
    dateticks = range(t0, t1, step=tinc) |> collect
    dateticks = modify_fn(dateticks)

    xticks, xticklabels = ticklabelconvert(t0, t1, t10, x0, x1, x10, dateticks, datestrformat)

    ax2.xticks[] = (xticks, xticklabels)
end

function ticklabelconvert(t0, t1, t10, x0, x1, x10, dateticks, datestrformat)
    xticks = ((dateticks .- t0) ./ t10) .* x10 .+ x0
    xticklabels = Dates.format.(dateticks, datestrformat)
    return xticks, xticklabels

end


function _datetimetick0(t, x_a)
    if length(t) != length(x_a)
        error("t and x should be the same length.")
    end

    t0, t1 = extrema(t)
    x0, x1 = extrema(x_a)
    t10 = t1 -t0
    x10 = x1 -x0
    # t0, t1 = map(f -> f(t), [minimum, maximum])
    # t10 = t1 -t0
    # x0, x1 = map(f -> f(x_a), [minimum, maximum])
    # x10 = x1 -x0

    return t0, t1, t10, x0, x1, x10
end

"""
`blankaxis!(fpos, xmin::T, ymin::T, xmax::T, ymax::T) where {T<:AbstractFloat}`
creates an empty Makie Axis object at grid position `fpos`.

# Example
```julia
f = Figure(;resolution=(1400,1000))
gleft = f[1:3, 1] = GridLayout()
gright = f[1:3, 2:3] = GridLayout()
fpos = gright[0, :]
blankaxis!(fpos, xmin, ymin, xmax, ymax)
```
"""
function blankaxis!(fpos, xmin::T, ymin::T, xmax::T, ymax::T) where {T<:AbstractFloat}
    ax = CairoMakie.Axis(fpos,
        xticks = [xmin, xmax],
        yticks = [ymin, ymax],
        bottomspinevisible = false,
        leftspinevisible = false,
        xticklabelsvisible = false,
        yticklabelsvisible = false,
        xgridvisible = false,
        ygridvisible = false,
        topspinevisible = false,
        rightspinevisible = false,
    )
return ax
end

"""
`expandylim!(ax, upper_expand)` expand the upper limit of y axis to a ratio of `upper_expand` of the original y range (`ymax - ymin`).

# Example
```julia
expandylim!(ax, 0.25)
```

"""
function expandylim!(ax, upper_expand)
    xmin, ymin, xmax, ymax = getxylimits(ax)
    diffy0 = ymax - ymin
    newymax = ymin + diffy0*(1+upper_expand)
    ylims!(ax, ymin, newymax)
end

"""
`shrinkylim!(ax, ydatas::Vector{<:Number}; extent = 0.15)`
fit y-limits to the input `ydatas` to with a certain `extent`.
"""
function shrinkylim!(ax, ydatas::Vector{<:Number}; extent = 0.15)
    ymin, ymax = extrema(vcat(ydatas...))
    # ymin = 0; ymax = 10
    Δy = ymax - ymin
    symin, symax = map((f, ym) -> f(ym, Δy*extent), [-,+], [ymin, ymax])
    ylims!(ax, symin, symax)
end


"""
# Example
```julia
xmin, ymin, xmax, ymax = getxylimits(ax)
```
"""
function getxylimits(ax)
    axlimtemp = ax.finallimits[]
    ((xmin, ymin), (xmax,ymax)) = map(f -> f(axlimtemp), (minimum, maximum))
    # see https://juliadatascience.io/glmakie
    return xmin, ymin, xmax, ymax
end


"""
`secondyaxis(f_grid; color = :black, ylabel = "y")` returns an `Axis` object of y axis to the right-hand side, with default settings for yyplot.

# Example
```julia
f = Figure()
ax_right = secondyaxis(f[1,1]; color=:red)


```
that you can do `lines!(ax_right, ...)`

# Further reading
- [Is it possible to add a secondary y axis?](https://github.com/JuliaPlots/Makie.jl/issues/816)
"""
function secondyaxis(f_grid; color = :black, ylabel = "y")
        axright = CairoMakie.Axis(f_grid; ylabel = ylabel,
        yaxisposition =:right,
        xlabelvisible =false,
        xticklabelsvisible =false,
        xticksvisible=false,
        xgridvisible = false,
        ygridvisible = false,
        ylabelcolor = color,
        yticklabelcolor= color,
        ytickcolor=color,
        yminortickcolor = color
    )
    return axright
end
