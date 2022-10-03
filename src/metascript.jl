"""
`manyscript(path_to_script0, ind_expr_newstrs::Pair...; append_info = false)`
creates a new script where the patterns in target lines are replaced by new `String`s or `SubstitutionString`s.

This function never overwrite old files; see also `pathnorepeat`.

If `append_info = true`, summary of the modified changes will be appended at the end of the new file.

# Example

```julia
for mm = 1:12 # test training/predicting timescale
    ind_expr_newstr = [66 => r"\\d+" => "$mm",
                        81 => r"tpast = \\d+" => "tpast = 12",
                        81 => r"tfuture = \\d+" => "tfuture = 2",
                        All() => r"includet" => "include"] # replace all "includet" by "include". The regular expression can match text across lines.
    manyscript(path_to_script0, ind_expr_newstr...)
end
```

# Tips and Tricks
## Comment or uncomment a certain line
```julia
ind_expr_newstr = [
    66 => r"^#\\s*" => "", # uncomment line 66
    77 => r"(^.)" => s"# \\1", # comment line 77
    All() => r"includet" => "include" # replace all "includet" by "include". In this case the regular expression matches text across lines.
    ]
manyscript(path_to_script0, ind_expr_newstr...)
```

Also see `reline!` and `replace`.

## Use regular expression to find the line for replacement
For `ind_expr_newstr` pair, if `ind` is regular expression, then it searches the only line with that matches the pattern.
e.g.,
```julia
ind_expr_newstr = [All() => r"includet" => "include",
                r"# run month by month" => r"^#\\s*" => "", # uncommentat the line
                r"# run month by month" => r"\\d+" => "$mm" # `reline!` on the line having the comment "# run month by month"
                ]
manyscript(path_to_script0, ind_expr_newstr...)
```


"""
function manyscript(path_to_script0, ind_expr_newstrs::Pair...; append_info = false)
    # e.g., path_to_script0 = thisdir("myexperiment.jl")
    lines = readlines(path_to_script0)

    for ind_expr_newstr in ind_expr_newstrs
        (ind, (expr, newstr)) = ind_expr_newstr
        reline!(lines, ind, expr, newstr)
    end

    newfname = pathnorepeat(path_to_script0)
    open(newfname, "w") do io
        # new doc
        for line in lines
            println(io, line)
        end
        if append_info # Comments at the end of doc
            for ind_expr_newstr in ind_expr_newstrs
                (ind, (expr, newstr)) = ind_expr_newstr
                comment_str = infoloop(ind, expr, newstr)
                println(io, comment_str)
            end
        end

    end
    return newfname
end

function infoloop(ind::Int, expr::Regex, newstr::Union{String, SubString})
    return "# at line [$ind]: $(expr.pattern) => $newstr"
end

function infoloop(ind::Regex, expr::Regex, newstr::Union{String, SubString})
    return "# at the only line that matches \"$ind\": $(expr.pattern) => $newstr"
end

"""
`reline!(lines, ind::Int, expr::Union{AbstractString, Regex}, newstr::AbstractString)` replace string that matches `expr` in `lines[ind]` by `newstr`.
`newstr` can be `SubstitutionString`. See the documentation of `replace` and `SubstitutionString`.

# WARNING: if `ind` is an integer or `ind = All()`, no warning or error pops if `expr` matches nothing such that nothing had changed. Use `reline!(lines, expr_findline::Regex, expr_replacecode::Regex, newstr::AbstractString)` if you want a warning or an error for non-exclusive matching.
"""
function reline!(lines, ind::Int, expr::Union{AbstractString, Regex}, newstr::AbstractString)
    lines[ind] = replace(lines[ind], expr => newstr)
end

"""
`reline!(lines, expr_findline::Regex, expr_replacecode::Union{AbstractString, Regex}, newstr::AbstractString)` replace string that matches `expr_replacecode` in `lines[ind]` by `newstr`, where `ind` indicates the line whose appending comment matches `expr_findline`.
`newstr` can be `SubstitutionString`. See the documentation of `replace` and `SubstitutionString`.
"""
function reline!(lines, expr_findline::Regex, expr_replacecode::Union{AbstractString, Regex}, newstr::AbstractString)
    ind = occursin.(expr_findline, lines)
    ntargets = sum(ind)
    if ntargets > 1
        error("Multiple targets matched by the expression; this error is raised to prevent unintended mismodification.")
    elseif ntargets <1
        @warn "No line matched for expression $(expr_findline); no modification for this entry."
    end

    reline!(lines, findfirst(ind), expr_replacecode, newstr)
    # lines[ind] = replace(lines[ind], expr_replacecode => newstr)
end


"""
`reline!(lines, ind::All, expr, newstr::AbstractString)` replace the pattern matched by `expr` with `newstr` in the scope of `fullscript = join(lines, "\n")`.
"""
function reline!(lines, ind::All, expr, newstr::AbstractString)
    fullscript = join(lines, "\n")
    fullscript = replace(fullscript, expr => newstr)
    lines .= split(fullscript, "\n")
end

"""
Noted that the script to include shares the scope of SWCForecast module.
"""
function runallscript(thisdir::Function; ref="myexperiment.jl")
    exprstrs = insert!([splitext(ref)...], 2, "(\\_|\\s).*")
    scriptexpr = Regex(join(exprstrs))# e.g., r"myexperiment(\_|\s).*.jl"
    scriptlist = filelist(scriptexpr, thisdir())
    for script in scriptlist
        replacerewrite(script, ref, basename(script))
        # replace the original file name (e.g., `"myexperiment.jl" => "myexperiment_0001.jl"`)
        # in every new script
        include(script)
    end
    rm.(scriptlist)
end


"""
replace certain keyword in the entire script
"""
function replacerewrite(path2script::AbstractString, expr, newstr)
    lines = readlines(path2script)
    replacerewrite!(lines, expr, newstr)
    open(path2script, "w") do io
        for line in lines
            println(io, line)
        end
    end
end

function replacerewrite!(lines::Vector{<:AbstractString}, expr, newstr)
    for (i,line) in enumerate(lines)
        reline!(lines, i, expr, newstr)
    end
end
