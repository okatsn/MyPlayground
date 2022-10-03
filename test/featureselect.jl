@testset "featureselectbyheadkey" begin
    using DataFrames
    df = DataFrame(
        :air_temperature => randn(10),
        :precipitation => randn(10),
        :humidity => randn(10),
        :soil_water_content => randn(10),
        :pressure => randn(10),
        :hour => rand(collect(0:23), 10)
    )

    feat0 = ["hour", "pressure", "precipitation"]

    (X0,) = series2supervised(df => [-1,-2,-3])

    ans1 = featureselectbyheadkey(X0, feat0)
    ans2 = featureselectbyheadkey(X0, [feat0]) |> first
    ans0 = SWCForecast._featureselectbyheadkey_test(X0, [feat0]) |> first
    ans00 = [
        Symbol("hour_t-1"),
        Symbol("hour_t-2"),
        Symbol("hour_t-3"),
        Symbol("pressure_t-1"),
        Symbol("pressure_t-2"),
        Symbol("pressure_t-3"),
        Symbol("precipitation_t-1"),
        Symbol("precipitation_t-2"),
        Symbol("precipitation_t-3"),
    ]
    @test isequal(ans1, ans2)
    @test isequal(ans1, ans0)
    @test isequal(ans00, ans0)
end
