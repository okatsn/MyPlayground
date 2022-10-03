using CSV
using DataFrames
using DataFrameTools, FileTools, Shorthands
using Dates
using Statistics
using Printf
using Test

using Revise
using SWCForecast

flist = filelist(r".*\.csv\Z", interimdatadir())

file = flist[end]

for file in flist
    df = CSV.read(file, DataFrame)
    tag = basename(file)

    @testset "Is datetime in $tag continuous?" begin
        dtstep = diff(df.datetime) |> unique |> get1var
        # make sure there is no missing in datetime
        @test isequal(collect(range(extrema(df.datetime)..., step=dtstep)), df.datetime) # test if datetime is continuous

        @test isequal(df.datetime, DateTime.(
            df.year,
            df.month,
            df.day,
            df.hour,
            df.minute)
) # make sure datetime and year, month, day... is consistent
    end


end

findall(diff(df.datetime) .== unique(diff(df.datetime))[2])


diff(df.datetime[8496:8497])
