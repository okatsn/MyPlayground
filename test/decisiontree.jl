import DecisionTree as DT
@testset "treeinspect!" begin
n_feat = 6 # number of variable
featnames = ["x_$i" for i in 1:n_feat]
featim = 3* randn(n_feat) .|> abs # impurity importance


dummyleaf = DT.Node(rand(1:n_feat), 11.2,
    DT.Leaf(8.0, randn(3)), DT.Leaf(13.3, randn(3))
)


leaf3a, leaf4a, leaf4b, leaf2b = (
                    DT.Leaf(3.0, 3.0 .+ randn(3)),
                    DT.Leaf(4.2, 4.2 .+ randn(5)),
                    DT.Leaf(5.0, 5.0 .+ randn(2)),
                    DT.Leaf(6.3, 6.3 .+ randn(4)),
                )
trunk3b = DT.Node(3, 4.5, leaf4a, leaf4b)  # split by feature 3 at level 3
trunk2a = DT.Node(2, 3.5, leaf3a, trunk3b) # split by feature 2 at level 2
trunk1 = DT.Node(1, 5.5, trunk2a, leaf2b) # split by feature 1 at level 1

DTR = DT.Root(trunk1, n_feat, featim)

FC0 = FeatureCounts(3)
treeinspect!(FC0, DTR)
df = SWCForecast.DataFrame(FC0; feature_names=featnames)
@test isequal(df.feature, ["x_1", "x_2", "x_3"])
@test isequal(df.level, [1, 2, 3])
@test isequal(df.value, [5.5, 3.5, 4.5])


FC = FeatureCounts(3)
treeinspect!(FC, DTR; only_at = 1)
df = SWCForecast.DataFrame(FC; feature_names=featnames)
@test isequal(df.feature, ["x_1"])
@test isequal(df.level, [1])
@test isequal(df.value, [5.5])

FC = FeatureCounts(3)
treeinspect!(FC, DTR; only_at = 2)
df = SWCForecast.DataFrame(FC; feature_names=featnames)
@test isequal(df.feature, ["x_2"])
@test isequal(df.level, [2])
@test isequal(df.value, [3.5])

FC = FeatureCounts(3)
treeinspect!(FC, DTR; only_at=3)
df = SWCForecast.DataFrame(FC; feature_names=featnames)
@test isequal(df.feature, ["x_3"])
@test isequal(df.level, [3])
@test isequal(df.value, [4.5])



FC1 = FeatureCounts(2)
treeinspect!(FC1, DTR; only_at=2)

FC2 = FeatureCounts(3)
treeinspect!(FC2, DTR; only_at=2)

FCX = FeatureCounts(99)
treeinspect!(FCX, DTR)

@test isequal(SWCForecast.DataFrame(FC1), SWCForecast.DataFrame(FC2))
@test isequal(SWCForecast.DataFrame(FC0), SWCForecast.DataFrame(FCX))

end
