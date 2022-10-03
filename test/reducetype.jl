@testset "reducetype.jl" begin
    v = [1,2,2.0,"str"] # a vector of any
    @test isequal(eltype(reducetype(v)), Union{Float64, Int64, String})

    v = [2.0,"str"] # a vector of any
    @test isequal(eltype(reducetype(v)), Union{Float64, String})

    v = ["str", missing] # a vector of any
    @test isequal(eltype(reducetype(v)), Union{Missing, String})

    v = ["str", missing, NaN] # a vector of any
    @test isequal(eltype(reducetype(v)), Union{Missing, String, Float64})

    v = ["str", 3.2, missing, NaN] # a vector of any
    @test isequal(eltype(reducetype(v)), Union{Missing, String, Float64})

    v = [9.7, 3.2, missing, NaN] # a vector of any
    @test isequal(eltype(reducetype(v)), Union{Missing, Float64})

end
