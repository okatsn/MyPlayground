# Convert ARI data
# Do this only once
using Dates
using Statistics
using Colors, ColorSchemes
using CSV
using DataFrames
using Printf
using Markdown
using MLJ
using MLJDecisionTreeInterface
using ShiftedArrays
# using PyPlot
# using Plots
# using TabularMakie, AlgebraOfGraphics
using CairoMakie
import Gadfly: plot as gdfplot, Geom,Guide, PNG, cm, draw, Scale

using DataFrameTools, FileTools, Shorthands
using Test
using Revise
using SWCForecast

csvpaths = filelist(r"\ATowerNCU", interimdatadir("old"))

for csvpath in csvpaths
    df0 = csvpath |> x -> CSV.read(x, DataFrame)
    df1 = deepcopy(df0)
    select!(df1, All() .=> identity .=> (x -> lowercase(x)))



    toreplace = [
        r"\Atemperature" =>  "air_temperature",
        r"rain(\d+)" => s"precipitation_\1mm",
        r"precipitation\Z" => "precipitation_05mm",
        r"soil_water_conten_" => "soil_water_content_",
        r"soil_water_content?_(\d+)_(\d+)cm" => s"soil_water_content_#\1_\2cm",
        r"cwb_(\w+)" => s"\1_CWB"
    ]

    for p in toreplace
        select!(df1, All() .=> identity .=> (x -> replace(x, p)))
    end

    @test isequal(get1var(df0, r"(Soil_water_content_10cm|Soil_water_conten_10cm)"), df1.soil_water_content_10cm)
    @test isequal(df0.CWB_Humidity, df1.humidity_CWB)
    @test isequal(df0.hour, df1.hour)
    oldname = basename(csvpath)
    yrstr = match(r"(?<=Data)\d+", oldname).match
    CSV.write(pathnorepeat(interimdatadir("TowerNCU_Li-Data$yrstr.csv")), df1)
end


savedcsvpaths = filelist(r"\ATowerNCU", interimdatadir())
for spath in savedcsvpaths
    CSV.read(spath, DataFrame) |> names |> show_all
end


oldcsvpaths = filelist(r"\ATowerNCU", interimdatadir("old"))
for spath in oldcsvpaths
    CSV.read(spath, DataFrame) |> names |> show_all
end
