# todo: View over precipitation of every months 2018

t0t1 = df_app.datetime |> extrema
dfff = filter(row -> t0t1[1]< row.datetime <t0t1[end], df_full)

dfacp = stack(dfff, [:accumulated_precipitation_1day, :accumulated_precipitation_samp1min_1day,  :soil_water_content_10cm], [:datetime])
plt = Gadfly.plot(dfacp, x=:datetime, ygroup=:variable, y=:value, Geom.subplot_grid(Geom.line, free_y_axis=true), Gadfly.Theme(key_position=:bottom), Guide.title("Accumulated Precipitation ($fnameyear)"))
draw(Gadfly.SVGJS(presentationdir("src/assets/img/AccumulatedPrecipitations.svg")), plt)
