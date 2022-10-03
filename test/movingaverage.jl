@testset "mvwinmean" begin
    @test isequal(mvmean(collect(2.0:6.0), 2), [2.5,3.5,4.5,5.5])
    y = randn(10);
    n = 3;
    @test isapprox(mvmean(y, n), SWCForecast.moving_average(y,n))
    @test isequal(mvnanmean([1.0, 2.0, 3.0, NaN, 5.0],2), [NaN, 1.5,2.5,1.5,2.5])
    @test isequal(mvnanmean([1.0, 2.0, 3.0, NaN,NaN, 5.0],2), [NaN, 1.5,2.5,1.5,0.0,2.5]) # WARN: all NaN in the moving window results zero, NOT NaN.

    @test isequal(slowmvnanmean([1.0, 2.0, 3.0, NaN,NaN, 5.0],2), [NaN, 1.5,2.5,1.5,NaN,2.5])
end
