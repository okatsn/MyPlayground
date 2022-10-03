
@testset "test hide_section" begin
    str = """

    #hide-below
    a = 1+1
    b = 2+3;

    @md_str "bla"
    #hide-above
    # Lulala
    # don't hide me!

    #hide-below
    Markdown.parse() # bla
    #hide-above
    """
    str1 = SWCForecast.hide_section(str)
    @test occursin(r"don't hide me!", str1)
    @test occursin(r"Lulala", str1)
    @test !occursin(r"Markdown\.parse", str1)
    @test !occursin(r"a = 1+1", str1)
    @test !occursin(r"b = 2+3", str1)
    @test !occursin(r"@md_str \"bla\"", str1)
end

@testset "iscommented" begin
    script = """
    # https://otexts.com/fpp2/simple-methods.html
    # mean, naive, Seasonal naïve
    # Box-Cox transformations
    # MLJModels: ConstantRegressor

    # [MLJ cheatsheet](https://alan-turing-institute.github.io/MLJ.jl/stable/mlj_cheatsheet)
    # [Common MLJ Workflows](https://alan-turing-institute.github.io/MLJ.jl/dev/common_mlj_workflows/)

    using Dates
    using Statistics
    using Random
    using Colors, ColorSchemes
    using Chain
    using CSV
    using DataFrames
    using Impute
    using Printf
    using MLJ

    # For Particle swarm optimization
    using MLJ, MLJDecisionTreeInterface, MLJParticleSwarmOptimization


    using MLJDecisionTreeInterface
    using ShiftedArrays
    # using PyPlot
    # using Plots
    # using TabularMakie, AlgebraOfGraphics
    using CairoMakie
    import Gadfly
    import Gadfly: plot as gdfplot, Geom,Guide, PNG, cm, draw, Scale

    using DataFrameTools, FileTools, Shorthands
    using HypertextTools
    using Revise
    using SWCForecast

    swcdepth=10 # SETME: it can be 10, 30, 50, 70, 100, 150cm
    thisdir(args...) = projectdir(trainingdir("decisiontree_20220527"), args...)# SETME
    presentationdir(args...) = thisdir("presentation", args...)

    using Markdown, HypertextLiteral
    includet(thisdir("myfunctions.jl"))
    scriptpath = thisdir("experiment_ARI.jl")
    exp_resultdir = mkresultdir(scriptpath)
    hash_script = match(exprgethash, exp_resultdir()).match


    # RandomForestRegressor, DecisionTreeRegressor
    DDT = DescriptOneForest(exp_resultdir) # SETME: description type
    model = (@load "RandomForestRegressor" pkg = "DecisionTree" verbosity = 0)() # SETME: regressor type

    # You'd like to try [EnsembleModel](https://alan-turing-institute.github.io/MLJ.jl/stable/homogeneous_ensembles/#Homogeneous-Ensembles) for an alternative Random Forest.
    # Since julia's decision tree is not well documented; you might find [sklearn.ensemble.ExtraTreesRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.ExtraTreesRegressor.html) useful

    model.min_samples_leaf = 10 # hint from matlab
    model.n_trees = 50 # 50 seems to be sufficient # SETME: enable n_trees only when it is forest

    mypipe = Pipeline(
        selector = FeatureSelector(),
        model = model
    )
    DDT.model = mypipe
    mymeasures = [MLJ.mae]
    # mymeasures = [(ŷ, y) -> mymse(ŷ, y)]
    # you must make a custom measure function anonymous; otherwise, deserialization will fail (`machine("machine.jlso")`). For, built-in measure functions, use them directly (e.g., [mae, rmse]).

    # measures(model) |> show_all # do nothing # use `measures()` to list all measures
    # random forest:
    # https://alan-turing-institute.github.io/MLJ.jl/stable/machines/#Machines
    # https://docs.juliahub.com/MLJ/rAU56/0.14.0/tuning_models/#Tuning-multiple-nested-hyperparameters-1
    # Forest and tuned model example: https://discourse.juliacn.com/t/topic/4018
    # todo: try different measure methods; use type or Dict to automatic show the correct y label in plots; Also modify all "MAE"blablabla


    # Series data to supervised data
    # tpast = range(0; step=-6, length=4) |> collect # SETME: shifted times for input features
    tpast = [0,-2,-4,-6,-12,-18,-24,-48,-72,-144,-288] # SETME: custom shifted times for input features
    tfuture = [1]; # SETME: shifted times for output prediction

    # or alternatively: tpast = range(0; step=-1, length=6) |> collect

    ## Main process
    # Setting
    # Random.seed!(1) # KEYNOTE: non-fixed random seed

    paths = filelist(r"\\AARI", interimdatadir())
    # (ax, f) = filecolumnview(paths) # view the variables in data over files
    datafile = paths[1]
    fnameyear = match(r"(?<=\\A|\\D)20\\d{2}(?=\\z|\\D)", basename(datafile)).match
    df_full = CSV.read(datafile,DataFrame)# add `; dateformat="yyyy/mm/dd HH:MM"` if first column is a vector of datetime strings.

    transform!(df_full, [:year, :month, :day, :hour, :minute] => ByRow(DateTime) => :datetime)
    preview(df_full[!, [:datetime, :year, :month, :day, :hour, :minute]], 20)

    apd = Dict( # time intervals to accumulates precipitation
        "1hour" => 6,
        "12hour" => 6*12,
        "1day" => 6*24,
        "2day" => 6*24*2,
        "3day" => 6*24*3
    )
    """

    script1 = """


    using Dates
    using Statistics
    using Random
    using Colors, ColorSchemes
    using Chain
    using CSV
    using DataFrames
    using Impute
    using Printf
    using MLJ

    using MLJ, MLJDecisionTreeInterface, MLJParticleSwarmOptimization


    using MLJDecisionTreeInterface
    using ShiftedArrays
    using CairoMakie
    import Gadfly
    import Gadfly: plot as gdfplot, Geom,Guide, PNG, cm, draw, Scale

    using DataFrameTools, FileTools, Shorthands
    using HypertextTools
    using Revise
    using SWCForecast

    swcdepth=10 # SETME: it can be 10, 30, 50, 70, 100, 150cm
    thisdir(args...) = projectdir(trainingdir("decisiontree_20220527"), args...)# SETME
    presentationdir(args...) = thisdir("presentation", args...)

    using Markdown, HypertextLiteral
    includet(thisdir("myfunctions.jl"))
    scriptpath = thisdir("experiment_ARI.jl")
    exp_resultdir = mkresultdir(scriptpath)
    hash_script = match(exprgethash, exp_resultdir()).match


    DDT = DescriptOneForest(exp_resultdir) # SETME: description type
    model = (@load "RandomForestRegressor" pkg = "DecisionTree" verbosity = 0)() # SETME: regressor type


    model.min_samples_leaf = 10 # hint from matlab
    model.n_trees = 50 # 50 seems to be sufficient # SETME: enable n_trees only when it is forest

    mypipe = Pipeline(
        selector = FeatureSelector(),
        model = model
    )
    DDT.model = mypipe
    mymeasures = [MLJ.mae]



    tpast = [0,-2,-4,-6,-12,-18,-24,-48,-72,-144,-288] # SETME: custom shifted times for input features
    tfuture = [1]; # SETME: shifted times for output prediction



    paths = filelist(r"\\AARI", interimdatadir())
    datafile = paths[1]
    fnameyear = match(r"(?<=\\A|\\D)20\\d{2}(?=\\z|\\D)", basename(datafile)).match
    df_full = CSV.read(datafile,DataFrame)# add `; dateformat="yyyy/mm/dd HH:MM"` if first column is a vector of datetime strings.

    transform!(df_full, [:year, :month, :day, :hour, :minute] => ByRow(DateTime) => :datetime)
    preview(df_full[!, [:datetime, :year, :month, :day, :hour, :minute]], 20)

    apd = Dict( # time intervals to accumulates precipitation
        "1hour" => 6,
        "12hour" => 6*12,
        "1day" => 6*24,
        "2day" => 6*24*2,
        "3day" => 6*24*3
    )
    """
    @test iscommented("# Dict(# time")
    @test iscommented("# SETME: regressor type")
    @test iscommented("## Also commented")
    @test iscommented("# filter!(:datetime => filterbydt(\"dtstr0\", \"dtstr1\"), df_app) # filter by a certain month in this year")
    @test iscommented("#filter!(:datetime => filterbydt(\"dtstr0\", \"dtstr1\"), df_app) # filter by a certain month in this year")
    @test iscommented(" #filter!(:datetime => filterbydt(\"dtstr0\", \"dtstr1\"), df_app) # filter by a certain month in this year")
    @test iscommented(" # allfeat |> show_all")
    @test !iscommented("occursin(r\"^(\\s*#)\", oneline)")
    indcode, alllines = onlycodelines(script)
    @test isequal(alllines[indcode], split(script1,"\n"))

    @test iscommentedand("# Dict(# time", "D")
    @test iscommentedand("# SETME: regressor type", "SETME")
    @test !iscommentedand("## SETME: regressor type", "SETME")
    @test !iscommentedand("occursin(r\"^(\\s*#)\", oneline)","occursin")

end

@testset "removetag" begin
    @test isequal("# Overview on data availability \n",
    removetag("# Overview on data availability # TODO: filter df_full and plot \n", "TODO"))

    @test isequal("",
    removetag("# TODO: make imputeinterp! that use interpolation methods to impute. See", "TODO"))

    @test isequal("occursin.(\"TODO\")",
        removetag("occursin.(\"TODO\")", "TODO"))
    @test isequal("occursin.(\"TODO\")",
        removetag("occursin.(\"TODO\")", "todo"))
    @test isequal("isequal(vartodo, TODO, todo) #",
        removetag("isequal(vartodo, TODO, todo) ## TODO: blatodo", "TODO"))
    @test isequal("isequal(vartodo, TODO, todo) ",
        removetag("isequal(vartodo, TODO, todo) ", "TODO"))
    @test isequal("isequal(vartodo, TODO, todo) # This TODO in the line shouldn't be removed\n",
        removetag("isequal(vartodo, TODO, todo) # This TODO in the line shouldn't be removed\n", "TODO"))
    # @test isequal("",
    # removetag("", "TODO"))

    # @test isequal("",
    # removetag("", "todo"))

    @test isequal("    select!(df, All() .=> (x -> all(ismissing.(x)) ? 999 : x); renamecols=false) # nottodo if all missing then 999 ",
        removetag("    select!(df, All() .=> (x -> all(ismissing.(x)) ? 999 : x); renamecols=false) # nottodo if all missing then 999 ", "todo"))
    @test isequal("    select!(df, All() .=> (x -> all(ismissing.(x)) ? 999 : x); renamecols=false) # if all missing then 999 # todo: need test",
        removetag("    select!(df, All() .=> (x -> all(ismissing.(x)) ? 999 : x); renamecols=false) # if all missing then 999 # todo: need test", "TODO"))
    @test isequal("    select!(df, All() .=> (x -> all(ismissing.(x)) ? 999 : x); renamecols=false) # if all missing then 999 ",
        removetag("    select!(df, All() .=> (x -> all(ismissing.(x)) ? 999 : x); renamecols=false) # if all missing then 999 #  todo: need test", "todo"))
end
