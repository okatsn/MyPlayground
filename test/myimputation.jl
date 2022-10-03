using DataFrames
using Statistics
df0 = DataFrame(
    :one_missing => [1.0,2.0,3.0,missing,5.0, 6.0],
    :most_general => [1.0,missing,3.0,NaN,5.0, 6.0],
    :all_missing => fill(missing, 6),
    :all_nan => fill(NaN, 6),
    :mix_nanmissing => [NaN, missing, NaN, missing, missing, NaN]
)

@testset "imputemean!" begin
    df = deepcopy(df0)
    imputemean!(df)
    @test df.one_missing[4] == mean([1,2,3,5,6])
    @test df.most_general[2] == mean([1,3,5,6])
    @test isequal(df.all_nan, fill(999, 6))
    @test isequal(df.all_missing, fill(999, 6))
    @test isequal(df.mix_nanmissing, fill(999, 6))
    @test !any(x -> isnan(x)|ismissing(x), Matrix(df))
end


@testset "imputeinterp!" begin
    df = deepcopy(df0)
    imputeinterp!(df)
    @test df.one_missing[4] == 4.0
    @test df.most_general[2] == 2.0
    @test df.most_general[4] == 4.0
    @test isequal(df.all_nan, fill(999, 6))
    @test isequal(df.all_missing, fill(999, 6))
    @test isequal(df.mix_nanmissing, fill(999, 6))
    @test !any(x -> isnan(x)|ismissing(x), Matrix(df))
end

@testset "isoutofrange" begin
    @test !SWCForecast.isoutofrange(10,0,100)
    @test SWCForecast.isoutofrange(10.0,11,100)
end

@testset "outer2missing" begin
    df = deepcopy(df0)
    colnames = [:one_missing, :most_general]
    limits = (2.0,5.0)
    l0, l1 = limits
    SWCForecast.outer2missing!(df, colnames, limits)
    @test ismissing(df.one_missing[1])
    @test df.one_missing[5] == 5.0
    @test ismissing(df.one_missing[6])
    imputemean!(df)
    M = Matrix(df[:, colnames])
    @test !any((M .< l0) .| (M .> l1))
end
