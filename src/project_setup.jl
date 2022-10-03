# https://juliadynamics.github.io/DrWatson.jl/stable/project/#Custom-directory-functions-1
notebooksdir(args...) = projectdir("notebooks", args...)

externaldatadir(args...) = datadir("0-external", args...)
rawdatadir(args...) = datadir("0-raw", args...)
interimdatadir(args...) = datadir("1-interim", args...)
finaldatadir(args...) = datadir("2-final", args...)
testdatadir(args...) = datadir("99-test", args...)

outputdir(args...) = projectdir("output", args...)
featuresdir(args...) = outputdir("features", args...)
modelsdir(args...) = outputdir("models", args...)
reportsdir(args...) = outputdir("reports", args...)
figuresdir(args...) = reportsdir("figures", args...)

trainingdir(args...) =  projectdir("training", args...)

mdtemplatedir(args...) = projectdir("src","myreport", "template", args...) # directory to templates for auto-generated reports.


"""
a type that should be a path
"""
abstract type MyPath end


struct AFolder <: MyPath
    function2path::Function
end

function AFolder(path::AbstractString)
    function2path(args...) = joinpath(path, args...)
    return AFolder(function2path)
end

struct AFile <: MyPath
    path::AbstractString
end
