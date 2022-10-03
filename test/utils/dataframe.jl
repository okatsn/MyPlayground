using DataFrames
@testset "utils: dataframe" begin
    df = DataFrame(; x=Any[i for i in 1:10], y=Union{Float64,Missing}[i for i in 1:10])
    narrow_types!(df)
    @test eltype.(eachcol(df)) == [Int64, Float64]

    df = DataFrame(; x=Any[i for i in 1:10], y=Union{Float64,Missing}[i for i in 1:10])
    df = convert_types(df, [:x => Float64, :y => Float64])
    @test eltype.(eachcol(df)) == [Float64, Float64]
end
