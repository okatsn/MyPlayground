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

csvpath = filelist(r"\AARI_Hsu.*\.csv", interimdatadir("old")) |> get1var
df0 = csvpath |> x -> CSV.read(x, DataFrame; dateformat="yyyy/mm/dd HH:MM")
select!(df0, "TIMESTAMP" => "datetime", Not(["TIMESTAMP"]))
transform!(df0, :datetime =>
            ByRow(x -> (year = year(x),
                month = month(x),
                day = day(x),
                hour = hour(x),
                minute = minute(x)
            )
        ) => AsTable
)

df1 = deepcopy(df0)

toreplace = [
    r"Soil_(\d+cm)_Avg" =>  s"soil_water_content_\1",
    r"T107_C_(\d+cm)_Avg" => s"soil_temperature_\1",
    r"Rain.*" => "precipitation",
]

for p in toreplace
    select!(df1, All() .=> identity .=> (x -> replace(x, p)))
end
@test isequal(df0.Soil_20cm_Avg, df1.soil_water_content_20cm)
@test isequal(df0.Soil_10cm_Avg, df1.soil_water_content_10cm)
@test isequal(df0.Soil_100cm_Avg, df1.soil_water_content_100cm)
@test isequal(df0.Rain_mm_Tot, df1.precipitation)

df1 = select!(df1, :datetime,:year, :month,:day,:hour,:minute, r"precipitation",r"soil_temperature" , r"soil_water")
CSV.write(pathnorepeat(csvpath), df1)
