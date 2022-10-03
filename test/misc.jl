
# Tests that are not depending on any source code of this project
@testset "misscellaneous" begin
    using DataFrames
    df = DataFrame(a=1:3, b=4:6, c=7:9)
    dfa = select(df, :, [:a, :b, :c] => ByRow((a, b, c) -> vcat(a, b, c)) => :abccat)
    dfb = select(df, :, [:a, :b, :c] => ByRow(vcat) => :abccat)
    @test isequal(dfa, dfb)
end
