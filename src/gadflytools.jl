# tools for gadflys

function plotlegendonly(args...)
    return (
        Geom.blank,
        Theme(; grid_line_width=0mm), # turn off gridline
        Guide.xticks(; ticks=nothing),
        Guide.yticks(; ticks=nothing),
        Guide.xlabel(""),
        Guide.ylabel(""),
        args...,
    )
end
