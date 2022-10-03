using CSV
using DataFrames
using DataFrameTools, FileTools, Shorthands
using Dates
using Statistics
using Printf
using Test

using Revise
using SWCForecast

flist = filelist(r"\ATowerNCU", interimdatadir())
df_all = DataFrame()
for f in flist
    df_main = CSV.read(f, DataFrame)
    append!(df_all, df_main; cols=:union)
end
# KEYNOTE: NO solar radiation, pressure, windspeed, winddirection in 2019 and 2020's data (noted at 2022-07-04)




all_precipstr = names(df_all, r"precipitation")

apd = Dict( # time intervals to accumulates precipitation
    "1hour" => 6,
    "12hour" => 6*12,
    "1day" => 6*24,
    "2day" => 6*24*2,
    "3day" => 6*24*3
)

addcol_accumulation!(df_all, all_precipstr, apd)






select!(df_all,Not(r"\Aprecipitation"),
AsTable(r"precipitation_(01|05)mm\Z") => ByRow(maximum) => "precipitation",
AsTable(r"precipitation_\d+mm_1hour\Z") => ByRow(maximum) => "precipitation_1hr",
AsTable(r"precipitation_\d+mm_12hour\Z") => ByRow(maximum) => "precipitation_12hr",
AsTable(r"precipitation_\d+mm_1day\Z") => ByRow(maximum) => "precipitation_1d",
AsTable(r"precipitation_\d+mm_2day\Z") => ByRow(maximum) => "precipitation_2d",
AsTable(r"precipitation_\d+mm_3day\Z") => ByRow(maximum) => "precipitation_3d"
)


CSV.write(interimdatadir("CombinedTowerNCU.csv"),df_all)
