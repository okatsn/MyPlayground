using Revise
using SWCForecast
using CSV, DataFrames, Gadfly, Dates, Compose
using Statistics
using Cairo, Fontconfig
using Colors
using HypertextLiteral

cd(projectdir())

notebooksdir("202202_dataview2018", "data2018_01_dfprocessing.jl") |> include # get processed dataframe `df`
notebooksdir("202202_dataview2018", "plotfunctions.jl") |> includet

# make sure n >= the maximum number of feature elements belongs to each group (plot)
n = 15
colors = distinguishable_colors(15, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)

defaultcolor = Scale.color_discrete_hue()
defaultcolor.f(3) # an example showing how to use

heatmapcolors = parse.(Colorant, ["lawngreen", "firebrick2", "black"])

targetstr = r"water_level"
plot_data2018(targetstr, df; 
    density_plot=[Coord.cartesian(xmin=-730, xmax=-440)], 
    rectbin_plot=[Scale.color_discrete_manual(heatmapcolors...)])

targetstr = r"water_temperature"
c = names(df, targetstr) |> length |> n -> defaultcolor.f(n) 

plot_data2018(targetstr, df; 
    timeseries_plot=[Scale.color_discrete_manual(c...)],
    density_plot=[Coord.cartesian(xmin=23.2, xmax=25.7), Scale.color_discrete_manual(c[[2,4,5,6,7]]...)], 
    rectbin_plot=[Scale.color_discrete_manual(heatmapcolors..., order=[2,1,3])])

targetstr = r"Soil_temperature"
plot_data2018(targetstr, df; 
    timeseries_plot=[Coord.cartesian(ymin=-10, ymax=80)],
    density_plot=[Coord.cartesian(xmin=-10, xmax=80)],
    rectbin_plot=[Scale.color_discrete_manual(heatmapcolors...)])


targetstr = r"Soil_water_content"
plot_data2018(targetstr, df; 
    density_plot=[Coord.cartesian(xmin=0, xmax=45)], 
    rectbin_plot=[Scale.color_discrete_manual(heatmapcolors...)])


