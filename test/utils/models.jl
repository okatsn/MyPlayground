using MLJ
@testset "models" begin
    @testset "decision tree regressor" begin
        Tree = @load "DecisionTreeRegressor" pkg = "DecisionTree" verbosity = 0
        tree = Tree()
        tree2 = load_decision_tree_regressor()
        @test tree == tree2

        tree = Tree(; max_depth=3)
        tree2 = load_decision_tree_regressor(; max_depth=3)
        @test tree == tree2
    end
end
