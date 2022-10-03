lines0 = ["scriptpath = thisdir(\"myexperiment.jl\")"
    ,"# or: model = load_decision_tree_regressor(; package=\"DecisionTree\")"
    ,"tree_type = @load \"DecisionTreeRegressor\" pkg = \"DecisionTree\" verbosity = 0"
    ,"model = tree_type()"
    ,"# measures(model) |> show_all # do nothing"
    ,""
    ,"includet(\"myfunction.jl\")"
    ,""
    ,"# https://juliaai.github.io/DataScienceTutorials.jl/getting-started/model-tuning/"
    ,"range_max_depth = range("
    ,"    model,"
    ,"    :max_depth;"
    ,"    lower=1,"
    ,"    upper=20, # upper-limit of tree depth"
    ,") # increase both the minumum and maximum depth of the tree (from 20 to 100) comparing to what ZK did (from 1 to 10); nothing else has been changed."
    ,"tuned_model = TunedModel(;"
    ,"    model=model,"
    ,"    tuning=Grid(; resolution=100), # for more about Grid, see strategies/grid.jl (use Grid |> methods to see the path)"
    ,"    resampling=TimeSeriesCV(; nfolds=24),"
    ,"    ranges=[range_max_depth],"
    ,"    measure=mae"
    ,"    # use `measures()` to list all measures"
    ,"    # full_report=true"
    ,")"
    ,""
]
import DataFrames: InvertedIndex
@testset "metascript.jl: replacerewrite!" begin
    lines = deepcopy(lines0)
    SWCForecast.replacerewrite!(lines, "myexperiment.jl" , "experiment_decisiontree_1.jl")
    @test lines[1] == "scriptpath = thisdir(\"experiment_decisiontree_1.jl\")"
    @test all(lines[InvertedIndex(1)] .== lines0[InvertedIndex(1)])
end

import DataFrames: All
@testset "metascript.jl: reline!" begin
    lines = deepcopy(lines0)
    SWCForecast.reline!(lines, 3, r"(?<=load).*(?=pkg)", " \"MyRegressor\" ")
    @test lines[3] == "tree_type = @load \"MyRegressor\" pkg = \"DecisionTree\" verbosity = 0"

    SWCForecast.reline!(lines, 21, r"(?<=measure\=).*", "newlossfunction")
    @test lines[21] == "    measure=newlossfunction"
    @test all(lines[InvertedIndex(3,21)] .== lines0[InvertedIndex(3,21)])
    @test lines[3] != lines0[3]
    @test lines[21] != lines0[21]


    SWCForecast.reline!(lines, r"# upper-limit of tree depth",
                                r"\d+",
                                "50")
    @test lines[14] == replace(lines0[14], r"\d+" => "50")

    SWCForecast.reline!(lines, All(), r"includet", "include")
    @test lines[7] == "include(\"myfunction.jl\")"
end
