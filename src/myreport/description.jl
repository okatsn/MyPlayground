"""
Functions that are used for generating `"description.toml"`.
For different a machine-learning algorithm or project, please create a corresponding type (struct) and use multiple dispatch.
"""

"""
`description!(D::AbstractDescription, d::Dict)` update `D.description` with `d` merged to it.
"""
function description!(DDT::AbstractDescription, d::Dict)
    recursive_merge!(DDT.description, d)
end

"""
`description!(DDT::AbstractDescription, str::AbstractString)` update `D.description` with string `str` merged to it.

# Example
```julia
str = "
    [database]
    server = "192.168.1.1"
    ports = [ 8001, 8001, 8002 ]
    ";
description!(DDT, str::AbstractString)
```
"""
function description!(DDT::AbstractDescription, str::AbstractString)
    description!(DDT, TOML.parse(str))
end


"""
`writedescription(D::AbstractDescription)` create file and print `D.description` to `"description.toml"`.
"""
function writedescription(DDT::AbstractDescription)
    path2toml = DDT.description_dir("description.toml")
    open(path2toml, "w+") do io
        TOML.print(io, DDT.description; sorted=true)
    end
    println("Here it is: $path2toml")
end

"""
`readdescription!(D::AbstractDescription)` read `"description.toml"` file and return the nested dictionary (i.e., `D.description` in `writedescription`); `D.description` will be overwritten by the loaded one.
"""
function readdescription!(DDT::AbstractDescription)
    path2toml = DDT.description_dir("description.toml")
    Ddescription = readdescription(path2toml)
    DDT.description = Ddescription
    return Ddescription
end

"""
`readdescription(path2toml::AbstractString)` read `"description.toml"` file and return the nested dictionary (i.e., `D.description` in `writedescription`).
"""
function readdescription(path2toml::AbstractString)
    Ddescription = TOML.parsefile(path2toml)
end


"""
Given the training machine `mach`, `description!(DDT::DescriptOneTree, mach::Machine)` update `DDT.description` with model information.
"""
function description!(DDT::DescriptOneTree, mach::Machine)
    tree_info = tree_structure(mach, DDT)

    mt = match(r"(?<=NumericRange\()\d+.*\s\d+","$(mach.model.range)")
    if isnothing(mt)
        TreeDepthRange = "error in retrieving the range"
    else
        TreeDepthRange = mt.match
    end


    dict_model_info = Dict(
        "Model" => Dict(
            "best_max_depth" => fitted_params(mach).best_model.max_depth,
            "features" => names(mach.data[1]),
            "measure" => "$(mach.model.measure)", # seems to be measure for optimization
            "Resampling" => Dict(
                "resampling" => "$(mach.model.resampling)",
                "nfolds" => mach.model.resampling.nfolds),
            "ModelInformation" => Dict(
                Iterators.map(
                    ((k, v),) -> string(k) => string(v), pairs(info(mach.model))
                ),
            ),
        ),
        "Tree" => Dict(
            "TreeDepthRange" => TreeDepthRange,
            "TreeStructure" => tree_info
        )
    )
    recursive_merge!(DDT.description, dict_model_info)
    # DDT.description = dict_to_toml
end


"""
Given the training machine `mach`, `description!(DDT::DescriptCompTree, mach::Machine)` update `DDT.description` with model information.
"""
function description!(DDT::DescriptCompTree, mach::Machine)
    tree_info = tree_structure(mach, DDT)
    mts = match.(r"(?<=NumericRange\()\d+.*max_depth.*\s\d+",string.(mach.model.range))
    mt = mts[.!isnothing.(mts)]
    if length(mt) != 1
        TreeDepthRange = "error in retrieving the range"
    else
        TreeDepthRange = mt[1].match
    end
    fitp = fitted_params(mach)
    feat_bestmodel = fitp.best_fitted_params.selector.features_to_keep .|> string
    mach_report = report(mach)
    modelsummarystr = dict2mdliststr(fitp.best_fitted_params.model)
    dict_model_info = Dict(
        "Model" => Dict(
            "best_max_depth" => mach_report.best_model.model.max_depth,
            "features" => feat_bestmodel,
            "measure" => "$(mach.model.measure)", # seems to be measure for optimization
            "Resampling" => Dict(
                "resampling" => "$(mach.model.resampling)",
                "nfolds" => mach.model.resampling.nfolds),
            "ModelInformation" => Dict(
                Iterators.map(
                    ((k, v),) -> string(k) => string(v), pairs(info(mach.model))
                ),
            ),
            "ModelSummary" => modelsummarystr,
        ),
        "Tree" => Dict(
            "TreeDepthRange" => TreeDepthRange,
            "TreeStructure" => tree_info
        )
    )
    recursive_merge!(DDT.description, dict_model_info)
    # DDT.description = dict_to_toml
end



"""
Given the training machine `mach`, `description!(DDT::DescriptOneForest, mach::Machine)` update `DDT.description` with model information.
"""
function description!(DDT::DescriptOneForest, mach::Machine)
    fitp = fitted_params(mach)
    feat_bestmodel = fitp.best_fitted_params.selector.features_to_keep .|> string
    mach_report = report(mach)

    modelsummarystr = dict2mdliststr(fitp.best_fitted_params.model)

    dict_model_info = Dict(
        "Model" => Dict(
            "best_max_depth" => mach_report.best_model.model.max_depth,
            "features" => feat_bestmodel,
            "measure" => "$(mach.model.measure)", # seems to be measure for optimization
            "Resampling" => Dict(
                "resampling" => "$(mach.model.resampling)",
                "nfolds" => mach.model.resampling.nfolds),
            "ModelSummary" => modelsummarystr,
            "ModelInformation" => Dict(
                Iterators.map(
                    ((k, v),) -> string(k) => string(v), pairs(info(mach.model))
                ),
            ),
        ),
    )
    recursive_merge!(DDT.description, dict_model_info)
    # DDT.description = dict_to_toml
end


"""
Given the training machine `mach`, `description!(DDT::DescriptEnsembleTrees, mach::Machine)` update `DDT.description` with model information.
"""
function description!(DDT::DescriptEnsembleTrees, mach::Machine)
    fitp = fitted_params(mach)
    feat_bestmodel = fitp.best_fitted_params.selector.features_to_keep .|> string
    mach_report = report(mach)

    modelsummarystr = dict2mdliststr(fitp.best_fitted_params.model)

    dict_model_info = Dict(
        "Model" => Dict(
            "best_max_depth" => mach_report.best_model.model.model.max_depth,
            "features" => feat_bestmodel,
            "measure" => "$(mach.model.measure)", # seems to be measure for optimization
            "Resampling" => Dict(
                "resampling" => "$(mach.model.resampling)",
                "nfolds" => mach.model.resampling.nfolds),
            "ModelSummary" => modelsummarystr,
            "ModelInformation" => Dict(
                Iterators.map(
                    ((k, v),) -> string(k) => string(v), pairs(info(mach.model))
                ),
            ),
        ),
    )
    recursive_merge!(DDT.description, dict_model_info)
    # DDT.description = dict_to_toml
end

"""
# Example
```julia
fitp = fitted_params(mach)
best_fitted_param_model = fitp.best_fitted_params.model # which should be a `Dict`

dict2mdliststr(best_fitted_param_model)

```

"""
function dict2mdliststr(best_fitted_param_model)
    bestparam_headers = keys(best_fitted_param_model) .|> string
    bestparam_strraws = values(best_fitted_param_model) .|> string

    bestparam_itemsets = []

    for (h, str) in zip(bestparam_headers,bestparam_strraws)
        strsubs = split(str, "\n")
        prefixing = fill("- ", length(strsubs))
        prefixing[1] = ""
        push!(bestparam_itemsets, join(prefixing .* strsubs, " \n "))
    end

    modelsummarystr = join(bestparam_itemsets, "\n \n ")
    return modelsummarystr
end
