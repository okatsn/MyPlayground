function stacksummary(targetstr, df; stackagainst=[:datetime])
    dfp = stack(df, targetstr, [:datetime]) # "long" version of `df`
    dfpn = filter(:value => x -> !ismissing(x) && !isnan(x), dfp) # drop missing and nan
    gdpn = groupby(dfpn, :variable)
    summarytable = combine( gdpn, :value .=> [mean, std] .=> ["mean","std"])
    return dfp, dfpn, summarytable
end

function plot_data2018(targetstr, df; density_plot=[], timeseries_plot=[], rectbin_plot=[], all_plot=[])
    dfp, dfpn, summarytable = stacksummary(targetstr, df)
    fontsize_tsds = (major_label_font_size=12pt,
                     minor_label_font_size=10pt,
                     point_label_font_size=10pt,
                     key_label_font_size=10pt,
                     key_title_font_size=12pt)
    transform!(dfp, :value => ByRow(x -> describeinstr(x)) => :validity )

    ## data heatmap plot
    # Gadfly.set_default_plot_size(15cm, 5cm)
    p_data = plot(dfp, x=:datetime, y=:variable, color=:validity, Geom.rectbin, rectbin_plot..., all_plot...,
        Theme(major_label_font_size=5pt, minor_label_font_size=4pt, key_label_font_size=4pt, key_title_font_size=6pt)) |> p -> draw(PNG(10cm, 5cm, dpi=200),p)

    ## timeseries plot
    Gadfly.set_default_plot_size(20cm, 8cm)
    p_ts = plot(dfp, x=:datetime,y=:value,color=:variable, Geom.line,
    Theme(;fontsize_tsds..., key_position=:right), timeseries_plot..., all_plot...)
    # Theme(key_position = :none)
    display(p_ts)

    ## density plot
    p_ds = plot(dfpn, x=:value, color=:variable, Geom.density,
            Theme(;fontsize_tsds..., key_position=:right),
              Guide.ylabel("density"), density_plot..., all_plot...)
    display(p_ds)
    # p_ld = plot(dfpn, x=:value, color=:variable,
    #         plotlegendonly(Guide.colorkey(title="variable", pos=[0.55w,-0.15h]))...
    #         );
return summarytable
end



function table_data2018(summarytable)
    strround(float, n) = string(round(float; digits=n))
    render_row(nt_summary_i) = @htl("""
    <tr>
        <td> $(nt_summary_i.variable)
        <td> $(strround(nt_summary_i.mean, 2))
        <td> $(strround(nt_summary_i.std,2))
    </tr>
    """) # if ... else statement is accepted e.g., $(if nt_summary_i.mean > 5 "✔️" else "❌" end)

    nt_summary = copy.(eachrow(summarytable))
    varname = uppercasefirst.(split(summarytable[1,1], "_")[1:end-1]) |> str -> join(str, " ")
    @htl("""
    <table>
        <caption> Summary for <b>$varname</b>: </caption>
        <tr><th> variable
            <th> mean
            <th> standard deviation
        </tr>

        $((render_row(nt_summary_i) for nt_summary_i in nt_summary))


    </table>
    """)
end
