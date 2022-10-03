using CSV
using DataFrames
using DataFrameTools, FileTools, Shorthands
using Dates
using Statistics
using Printf
using Test

using Revise
using SWCForecast

fpath = interimdatadir("Jiufenersha_C1I230_201801.csv")
df = CSV.read(fpath, DataFrame)

# insert the dummy column "minute"
insertcols!(df,findfirst(occursin.("hour", names(df)))+1, :minute => 0)

transform!(df, [:year, :month, :day, :hour] => ByRow(DateTime) => :datetime)


CSV.write(fpath, df)


flist = filelist(r"\ATower.*\.csv\Z", interimdatadir())
for file in flist
    fpath = file
    df = CSV.read(fpath, DataFrame)

    transform!(df, [:year, :month, :day, :hour,:minute] => ByRow(DateTime) => :datetime)

    CSV.write(fpath, df)
end
