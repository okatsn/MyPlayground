using CSV
using DataFrames
using DataFrameTools, FileTools, Shorthands
using Dates
using Statistics
using Printf
using Test
using Gadfly

using Revise
using SWCForecast


df_main = filelist(r"^ARI_Hsu-Data2022", interimdatadir("old")) |> get1var |> p -> CSV.read(p, DataFrame)
df_add = filelist(r"^Additional_ARI_G2F820_hour-Data202206", interimdatadir("old")) |> get1var |> p -> CSV.read(p, DataFrame)
df_add |> describe
# df_tower_NCU = filelist(r"^Tower.*2018", interimdatadir()) |> get1var |> p -> CSV.read(p, DataFrame)
# df_tower_NCU |> names |> show_all

transform!(df_add,:datetimestr => ByRow(dt -> Dates.DateTime(dt,"yyyy/mm/dd HH:MM:SS")) => :datetime)

transform!.([df_add,df_main], :datetime => ByRow(dt -> round(dt, Dates.Minute(10)));renamecols=false) # rounded the datetime column of both dataframes to 10 minutes (since in `df_main`, it is 00:00 while in `df_add`, it is 23:59).

df_merge = innerjoin(df_main, df_add, on = :datetime)
dt0, dt1 = df_main.datetime |> extrema
filter!(:datetime=> (dt -> dt0 <= dt <=dt1), df_merge)

@testset "sampling in df_main should gives identical results in df_merge" begin
    df_main_hour = filter(:minute=> (m -> m == 0), df_main)

    filter!(:datetime => (dt -> dt0 <= dt <=dt1), df_main_hour)
    @test isequal(df_merge[:, names(df_main)], df_main_hour[:, names(df_main)])


    @test diff(df_merge.datetime) |> unique |> get1var |> x -> isequal(x,Dates.Hour(1))
    # make sure there is no missing in datetime
    @test isequal(collect(range(extrema(df_merge.datetime)..., step=Dates.Hour(1))), df_merge.datetime) # test if datetime is continuous


    @test isequal(df_merge.datetime, DateTime.(
                                df_merge.year,
                                df_merge.month,
                                df_merge.day,
                                df_merge.hour,
                                df_merge.minute)
        ) # make sure datetime and year, month, day... is consistent
end

# Save
CSV.write(interimdatadir("ARI_Hsi_Combined_2022.csv"), df_merge)


# Plot
dfs = stack(df_merge, ["soil_temperature_50cm",
                "soil_temperature_100cm",
                "soil_temperature_50cm_G2F820",
                "soil_temperature_100cm_G2F820"],[:datetime])

plot(dfs, x=:datetime, y=:value, color=:variable, Geom.line)


names(df_merge)

dfs = stack(df_merge, names(df_merge, r"precipitation_"),[:datetime])

plot(dfs, x=:datetime, y=:value, color=:variable, Geom.point)


dfs = stack(df_merge, names(df_merge, r"soil_water_c"),[:datetime])

plot(dfs, x=:datetime, y=:value, color=:variable, Geom.line)
