"""
`markdownreport(DDT::AbstractDescription)` `Literate` the corresponding template in `mdtemplatedir()` generating the markdown report with all variables (informations) loaded from `DDT.description_dir("description.toml")`.
It automatically loads `"tmpl_\$typeofDDT.jl"` where `typeofDDT` is the type of `DDT`.

Also see `description`, `descrption!`, `readdescription`, `writedescription` for processing `"description.toml"`.
"""
function markdownreport(DDT::AbstractDescription)
    typeofDDT = typeof(DDT) |> string
    path2template = mdtemplatedir("tmpl_$typeofDDT.jl")
    path2toml = DDT.description_dir("description.toml")

    if !isfile(path2template)
        error("""
        The template for `Literate.markdown` does not exist. You have to add the template
        `"$path2template"` for the type `$typeofDDT` before you can proceed.
        """)
    end

    markdownreport(path2toml, path2template, DDT.description_dir())
end

"""
`markdownreport(path2toml, path2template, mdreport_dir)` `Literate` the corresponding template `path2template` generating the markdown report with all variables (informations) loaded from `path2toml`. The output markdown file is saved in `mdreport_dir`.

In your template (e.g., `"tmpl_XXXXXX.jl"` in `mdtemplatedir`), string `"PATH2TOML"` will be replaced by the variable `path2toml`.
"""
function markdownreport(path2toml, path2template, mdreport_dir)
    outputdir(args...) = joinpath(mdreport_dir, args...)
    oldfname = basename(path2template)
    newfname0 = "$(splitext(oldfname)[1]).md"

    f(x) = replace_path2toml(x, path2toml)
    g(x) = hide_section(x)
    Literate.markdown(path2template, outputdir(); preprocess = f, mdstrings=true, flavor=Literate.CommonMarkFlavor(),execute=true, postprocess=g, name=splitext(defaultmdname)[1]) # markdown created as `outputdir(newfname0)`
    # mv(outputdir(newfname0), outputdir(defaultmdname); force=true) # rename the file from `newfname0` to `defaultmdname`
end

"""
# Example
```julia
templatename = "tmpl_DescriptOneTree.jl"
result_dir = "/home/jovyan/swc-forecast-insider/training/decisiontree_20220330/my_result_0000"
markdownreport(templatename, result_dir; findin=r"RESULT")
```
"""
function markdownreport(templatename, result_dir; findin=r"RESULT")
    mdreport_dirs = folderlist(findin, result_dir)
    lenf = mdreport_dirs |> length
    path2templates = fill(mdtemplatedir(templatename), lenf)
    path2tomls = [joinpath(rdir, "description.toml") for rdir in mdreport_dirs]
    markdownreport.(path2tomls, path2templates, mdreport_dirs)
end


function replace_path2toml(str, tomlpath)
    str = replace(str, "PATH2TOML" => tomlpath)
end

function hide_section(str)
    hidesection_expr = Regex("(\\n*`+.*\\n)?#hide-below.*?#hide-above(\\n*`+)?","s") # "s" is the flag that makes "." also can be newline

    # because both #hide-below and # hide-above will be embraced by ````julia ```` after `Literate`. For example:
    # ````julia
    # #hide-below
    # ````
    # My message that should not shown on the final markdown file
    #
    # ````julia
    # #hide-above
    #
    #
    # ````

    # hidesection_expr = Regex("#hide-below.*?#hide-above","s") # "s" is the flag that makes "." also can be newline
    # hidesection_expr = Regex("blabla","s") # "s" is the flag that makes "." also can be newline

    str = replace(str, hidesection_expr => "")

end

"""
`iscommented(oneline::AbstractString)` returns `true` if the line is commented by `"#"`.
"""
function iscommented(oneline::AbstractString)
    occursin(r"^(\s*(//|#|%|<!--))", oneline)
end

"""
`iscommentedand(oneline::AbstractString, tag)` returns `true` if the line is commented and starts with `tag`.
"""
function iscommentedand(oneline::AbstractString, tag)
    occursin(Regex("^(\\s*(//|#|%|<!--))\\s*$tag"), oneline)
end

"""
`onlycodelines(script::AbstractString)` or `onlycodelines(scriptfile::AFile)` returns lines that are not commented. See also `iscommented`
"""
function onlycodelines(scriptfile::AFile)
    scriptpath = scriptfile.path
    jlvec = open(scriptpath) do file
        readlines(file)
    end
    idc = iscommented.(jlvec)
    return (.!idc , jlvec)
end

function onlycodelines(script::AbstractString)
    jlvec = split(script, "\n")
    idc = iscommented.(jlvec)
    return (.!idc , jlvec)
end

function trygetsourcecode(scriptpath, args...)
fpath = AFile(scriptpath)

lns = try
    indcode, lns = onlycodelines(fpath)
    for tag in args
        indcode = iscommentedand.(lns, tag) .| indcode
    end
    lns = lns[indcode]
catch e
    if isa(e, Base.SystemError)
        lns = ["File $scriptpath is no longer there and hence the source code is not available. ($(string(e)))"]
    else
        throw(e)
    end
end

lns .= removetag.(lns, "TODO")
lns .= removetag.(lns, "todo")
lns .= removetag.(lns, "FIXME")
lns .= removetag.(lns, "fixme")
lns .= removetag.(lns, "WARN")
lns .= removetag.(lns, "WARNING")

sourcecode = join(lns, " \n ")
return sourcecode
end

function removetag(oneline::AbstractString, rexpr::Regex)
    replace(oneline, rexpr => "")
end

function removetag(oneline::AbstractString, tag::AbstractString)
    rexpr = Regex("(//|#|%|<!--|;|/\\*|^|^[ \\t]*(-|\\d+.))\\s*($tag).*\\Z") # go to vscode's todo-tree setting
    removetag(oneline, rexpr::Regex)
end

"""
Simply return a empty `Markdown.MD` object.
"""
function emptyMD()
    return Markdown.parse("")
end
