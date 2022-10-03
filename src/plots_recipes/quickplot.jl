
"""
`quickdataoverview(df_all::DataFrame; gridwidth=Month(1), xname=:datetime, figsize=(23cm, 12cm))`
"""
function quickdataoverview(df_all::DataFrame; gridwidth=Month(1), xname=:datetime, figsize=(23cm, 12cm), output=nothing, output_backend = Gadfly.SVGJS)
    whichinterval = let
        ext0, ext1 = extrema(df_all[!, xname])
        dtgrid = range(ext0, ext1, step=gridwidth) |> collect # datetime grid for rectbin plot
        dft = DataFrame([lag(dtgrid) dtgrid], [:dt0, :dt1]) |> dropmissing
        append!(dft, DataFrame(:dt0 => dft.dt1[end], :dt1 => ext1))

        transform!(dft, [:dt0, :dt1] => ByRow((dt0, dt1) -> floor(mean(dt0, dt1), Day)) => :groupname) # See SWCForecast datenum.jl Statistics.mean(dt0, dt1)

        f = function whichinterval(dt)
            for df in eachrow(dft)
                if df.dt0 <= dt <= df.dt1
                    return df.groupname
                end
            end
            error("datetime is not belong to any interval")
        end
    end

    dftemp = @chain df_all begin
        DataFrames.transform(
            Symbol(xname) => ByRow(whichinterval) => :timetag)
        select(:timetag, Not([:timetag, Symbol(xname)]) .=> [ByRow(x -> ismissing(x) || isnan(x))]; renamecols=false)
        groupby(:timetag)
        combine(Not(:timetag) .=> mean ; renamecols=false)
        stack(Not(:timetag), :timetag; value_name = "missing rate")
    end

    p = Gadfly.plot(dftemp, x=:timetag, y=:variable, color=:"missing rate", Geom.rectbin)
    if !isnothing(output)
        draw(output_backend(output, figsize...), p)
    end
    return p
end
