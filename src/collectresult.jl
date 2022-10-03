
exprgethash = r"(?<=\A|[^a-zA-Z0-9])0x[a-zA-Z0-9]+(?=\z|[^a-zA-Z0-9])"
# hashtag = match(exprgethash, "RESULT_ExpeDeci_0x15b03b01222fec37").match



const expr_defaultmdname = r"brief\_report\.md"
const defaultmdname = "brief_report.md"

"""
Given a vector `strvec` the last few letters (e.g., ["ac23", "7df6"]) of the hashes, `compareresult(headerstr::AbstractString, strvec::Union{Vector{<:AbstractString}, Regex}, this_dir; fnameexpr=$expr_defaultmdname)` will collect specific sections of the markdown files in the folders that are suffixed by letters in `strvec` (e.g., `"RESULT_..._0x...7df6", `"RESULT_..._0x...ac23"`), with section header matching `headerstr`, and export a comparison markdown file in `this_dir`.

Noted that `strvec` can be a regular expression such as `r"RESULT"`; see `mdpaths` for how it searces the target markdown files.
"""
function compareresult(headerstr::AbstractString, strvec::Union{Vector{<:AbstractString}, Regex}, this_dir; fnameexpr=expr_defaultmdname)
    paths = mdpaths(fnameexpr, strvec, this_dir)
    foldernames = paths .|> dirname .|> basename
    hashtags = [mt.match for mt in match.(exprgethash, foldernames)]
    smds = SubMD.(paths, headerstr)
    trueheader = copy(smds[1].md.content[1].text)
    mdimgpath!.(smds, foldernames)
    appendheader!.(smds)
    combdoc = merge!(SubMD(), smds...)


    hashtags2 = ["`$htag`" for htag in hashtags]
    contents = [
        Markdown.Header{1}(["Comparing the Results"]),
        Markdown.Paragraph(["This is the comparision of the section ",
                            Markdown.Bold(trueheader),
                            " between results ",
                            join(hashtags2, ", ", ", and"),
                            "."
                            ])
    ]

    preface = merge!(md"", contents)
    (_, title) = level_text(headerstr)
    suffix_strs = []
    if length(combdoc.hash4) > 2
        push!(suffix_strs, combdoc.hash4[1:2]..., "etc")
    else
        push!(suffix_strs, combdoc.hash4...)
    end
    out_path = joinpath(this_dir, """COMPARE_$(title)_$(join(suffix_strs, "_")).md""")
    out_path = pathnorepeat(out_path)
    open(out_path, "w") do io
    print(io, merge!(preface, combdoc.md))
    end
    println("out_path: $out_path")
end

"""
`copysections(headerstr::AbstractString, strvec::Union{Vector{<:AbstractString}, Regex}, result_dir, presentationdir::Function; fnameexpr=expr_defaultmdname, oneslide=false, renameheader="", appendhash=false)`
reads `"$defaultmdname"` file in the target folders whose folder name matches `strvec`, and returns a vector `Markdown.MD` objects whose url for local images are relocated. This function is intended to return a vector of `Markdown.MD` objects with each element being one "slide" for [Remark.js](https://github.com/gnab/remark).

Noted that all images references by target files (those who name `"$defaultmdname"`) are copied to `presentationdir("src", "assets", "img")`, and the referenced paths to the images are relocated to `"assets/img/..."`.

# Keyword arguments
- `oneslide`: `strvec` given as regular expression, only the first slide is returned if `oneslide=true`. This is useful when the target section `headerstr` of all files in `result_dir` is roughly identical.
- `renameheader`: Set `md.content[1].text` as `renameheader`. For example, `, renameheader=["Hello ", Markdown.Bold(["World"])]`

# Example
Get the "Brief summary" sections in the markdown files `"brief_report.md"` across all `r"RESULT"` folders, concatenated as slides (separated by `---`):
```julia
headerstr = "## Brief Summary"
folderpattern = r"RESULT"
mds = copysections(headerstr, folderpattern, result_dir, presentationdir; fnameexpr="brief_report.md") |> join
```

A Literate example (one slide); the `oneslide=true` option returns only the first.
```julia
# ---
# ## Description

headerstr = "### Features" #hide
copysections(headerstr, r"RESULT", result_dir, presentationdir;oneslide=true)[1] #hide

# ---
```

A Literate example that returns slides, where there are total two slides with each page having the `"### Data overview"` and `"### Prediction"` sections:
```julia
# ---

strvec = ["052c", "9a2c"] #hide
headerstr = "### Data overview" #hide
mds = copysections(headerstr, strvec, resultdir0, presentationdir) #hide
headerstr = "### Prediction" #hide
mds2 = copysections(headerstr, strvec, resultdir0, presentationdir; appendhash=true) #hide
elwmerge!(mds, mds2) #hide
join(mds) #hide

# ---
```


# Tips
- The usage is similar to `compareresult`, but returns a vector `mds::Vector{Markdown.MD}` instead of one combined `Markdown.MD`. Use `join(mds)` to combine `mds` into one single `Markdown.MD`, separated by `"---"`.
- Use `elwmerge!` to combine the results elementwisely; this is useful if you want to have sections combined into one slide.
- Also see [Remark.jl](https://github.com/piever/Remark.jl).

"""
function copysections(headerstr::AbstractString, strvec::Union{Vector{<:AbstractString}, Regex}, result_dir, presentationdir::Function; fnameexpr=expr_defaultmdname, oneslide=false, renameheader="", appendhash=false)
    paths = mdpaths(fnameexpr, strvec, result_dir) # paths to original markdown files
    mdparentdirs = paths .|> dirname # directories to where these files are
    relativedir = mdparentdirs .|> basename # ["blabla", ...] # just the name of folders
    srcdirs = [srcdir(args...) = joinpath(absdir, args...) for absdir in mdparentdirs] # functions that see real images
    destdirs = [destdir(args...) = presentationdir("src", "assets", "img", rdir, args...) for rdir in relativedir]
    rdestdirs = [rdestdir(args...) = joinpath("assets", "img", rdir, args...) for rdir in relativedir]
    mds = getsection.(paths, headerstr) # returns a vector  or Markdown.MD
    copyimg.(mds, srcdirs, destdirs)
    # copyimg has to precede mdimgpath! (you have to copy image before modifying the img directories in the markdowns.)
    mdimgpath!.(mds, rdestdirs)


    # if oneslide
        # if all(mds .== mdsonly1)
            # mds = mdsonly1
        # else
            # I don't know why they are not identical
            # show(mds)
            # error("Obtained markdown sections are not identical; set `oneslide=false` to avoid this error.")
        # end
    # end

    if !isempty(renameheader)
        renamefirst!.(mds, [renameheader])
    end

    if appendhash
        foldernames = relativedir
        # hash4 = hashtag[end-3:end]
        hash4s = [mt.match[end-3:end] for mt in match.(exprgethash, foldernames)]
        appendheader!.(mds, hash4s)
    end
    if oneslide
        mdsonly1 = [first(mds)]
        mds = mdsonly1
    end

    return mds
end

"""
Merge `mds1` and `mds2` elementwisely.
"""
function elwmerge!(mds1::Vector{Markdown.MD}, mds2::Vector{Markdown.MD})
    for (md1, md2) in zip(mds1, mds2)
        SWCForecast.merge!(md1, md2)
    end
    return mds1
end

function renamefirst!(md::Markdown.MD, newobjs::Vector)
    md.content[1].text = newobjs
end

function SWCForecast.join(mds::Vector{Markdown.MD})
    delim = Markdown.HorizontalRule() # i.e., md"---"

    md0 = Markdown.MD([], first(mds).meta)
    for md in mds
        contents = md.content
        # contents = []
        # for mdci in md.content
        #     push!(contents, mdci, Markdown.Paragraph(["\n"]))
        # end
        push!(md0.content, contents..., delim)
    end

    pop!(md0.content)

    return md0
end

mdobj2str(mdc) = join(string.(mdc.text),"")

"""
Given a object `mdc`, `islevel(mdc, n)` returns true if `mdc` is the type of `Markdown.Header{n}`
"""
function islevel(mdc, n)
    return isa(mdc, Markdown.Header{n})
end

"""
Given a object `mdc`, `islevelleq(mdc, n)` returns true if `mdc` is the type of `Markdown.Header{x}` where `x ≤ n`. In brief, it recursively finds if it is a header of higher level (smaller `n`) until `n==0` (`false` is returned).
"""
function islevelleq(mdc, n)
    # do_next = true
    # while n > 0 && do_next
    #     do_next = !islevel(mdc, n)
    #     n = n - 1
    # end
    # isleq = !do_next
    # return isleq
    if n == 0
        return false
    elseif islevel(mdc, n)
        return true
    else
        islevelleq(mdc, n - 1)
    end
end

"""
Given a `Vector`, `targetrange(mdcs::Vector, nlevel, exprh::Regex)` find the target `Markdown.Header{nlevel}` object whose content matches `exprh`, returning a range which starts from this header to the next header `Markdown.Header{nlevelnext}` where `nlevelnext ≤ nlevel`.

Also see `islevel`, `islevelleq` and `targetsection`.
"""
function targetrange(mdcs::Vector, nlevel, exprh::Regex)
    ismatchlevel = islevelleq.(mdcs, nlevel)
    lenlv = length(ismatchlevel)
    thatlv = ismatchlevel |> findall
    thatheader = occursin.(exprh, mdobj2str.(mdcs[thatlv])) |> id -> thatlv[id]
    if length(thatheader) != 1
        error("Zero or multiple matches.")
    end
    targetheader = findfrom = thatheader[1]
    findafter = targetheader < lenlv ? thatheader[1] + 1 : lenlv
    nextheader = findnext(ismatchlevel, findafter)
    if isnothing(nextheader)
        finduntil = lenlv
    else
        finduntil = nextheader - 1
    end
    return findfrom:finduntil
end

"""
Given a `Markdown.MD` object, `targetsection(md1::Markdown.MD, nlevel, exprh)` returns the section (which is a `Vector`) that starts with the `Markdown.Header{nlevel}` object whose content matches `exprh` and ends until the next header `Markdown.Header{nlevelnext}` where `nlevelnext ≤ nlevel`.

Also see `targetrange`.
"""
function targetsection(md1::Markdown.MD, nlevel, exprh)
    mdcs = md1.content
    tr = targetrange(mdcs, nlevel, exprh)
    return mdcs[tr]
end

function getsection(md1::Markdown.MD, nlevel, exprh)
    mdobjs = targetsection(md1, nlevel, exprh)
    return Markdown.MD(mdobjs, md1.meta)
end

"""
Give the path of the markdown file, returns a `Markdown.MD` object of the section `headerstr`.

# Example
```julia
path = "/training/brief_report.md"
headerstr = "## Description"
getsection(path, headerstr)
```
In this example, the section starts from "## Description" and ends right before the next level 2 (e.g., "## blablabla") or level 1 (e.g., "# blabla") header; comments in code fences won't be recognized as a header.

Also see `SubMD`.
"""
function getsection(path::AbstractString, headerstr)
    (nlevel, htext) = level_text(headerstr)
    exprh = Regex(htext)
    md1 = Markdown.parse_file(path)

    return getsection(md1::Markdown.MD, nlevel, exprh)
end

"""
# Example
`level_text("## Introduction")` returns the header level and the appending string `(2, "Introduction")`.
"""
function level_text(headerstr)
    nlevel = match(r"^#+", headerstr).match |> length
    htext = match(r"[a-zA-Z0-9]+", headerstr).match
    # Alternatively:
    # hdr = match(r"(?<level>#+)[^a-zA-Z0-9]*(?<header>[a-zA-Z0-9]+)",headerstr)
    # hdr[:level]
    # hdr[:header]

    return (nlevel, htext)
end

"""
`result_folder_expr(strvec::Vector{<:AbstractString})` returns a single regular expression that should capture the directories for machine learning results.
For example, `result_folder_expr(["ac43"])`
    `"RESULT_...0x..."`
"""
function result_folder_expr(strvec::Vector{<:AbstractString})
    rawstr = "(?<=\\A|[^a-zA-Z0-9])0x[a-zA-Z0-9]*("*join(strvec, "|")*")(?=\\z|[^a-zA-Z0-9])"
    return Regex("$rawstr")
    # \w has already contain underscore (_)
    # \z matches only at the end of the subject
    # \A matches the start of a string
    # see https://www.pcre.org/original/doc/html/pcrepattern.html
    # noted that \W is equivalent to [^a-zA-Z0-9_]
end


mutable struct SubMD
    md::Markdown.MD
    header::Vector{AbstractString} # e.g., `["## Introduction"]`
    hash4::Vector{AbstractString} # e.g., `["c4a3"]`
    path::Vector{AbstractString} # e.g. `"/training/decisiontree_20220309/RESULT_ExpeDeci_0x15b03b01222fec37/brief_report.md"`
end

"""
Given the `path` to the markdown file and a string `headermatch`, `SubMD(path, headermatch)` returns a `SubMD` object.

# Fields
```
md::Markdown.MD
header::Vector{AbstractString} # e.g., `["## Introduction"]`
hash4::Vector{AbstractString} # e.g., `["c4a3"]`
path::Vector{AbstractString} # e.g. `"/training/decisiontree_20220309/RESULT_ExpeDeci_0x15b03b01222fec37/brief_report.md"`
```
"""
function SubMD(path, headermatch)
    foldername = path |> dirname |> basename
    # get hashtag from the name of its parent directory
    hashtag = match(exprgethash, foldername).match
    md = getsection(path, headermatch)
    hash4 = hashtag[end-3:end]
    SubMD(md, [headermatch], [hash4], [path])
end

"""
`SubMD()` create an empty `SubMD` object.
"""
function SubMD()
    md = md""
    SubMD(md, String[], String[], String[])
end

function SWCForecast.show(io::IO, smd::SubMD)
    lenc = length(smd.md.content)
    println(io, "md: A Markdown.MD object of $lenc elements.")
    println(io, "header: $(smd.header)")
    println(io, "last 4 digits of hash: $(smd.hash4)")
    println(io, "path: $(smd.path)")
end

"""
`mdpaths(fnameexpr::Regex, strvec::Vector, this_dir::AbstractString)` is
a shorthand to get the paths to target markdown files.

# Example
```julia
this_dir= "/training/decisiontree_20220309/"
fnameexpr = r"brief\\_report\\.md"
strvec = ["ac23", "7df6", "ddf", "c37"]

mdpaths(fnameexpr, strvec, this_dir)
```
which returns
```
4-element Vector{String}:
    "/training/decisiontree_20220309/RESULT_ExpeDeci_0x15b03b01222fec37/brief_report.md"
    "/training/decisiontree_20220309/RESULT_ExpeDeci_0x8a37ffc85c22eddf/brief_report.md"
    "/training/decisiontree_20220309/RESULT_ExpeDeci_0xa14053903286ac23/brief_report.md"
    "/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a362b941617df6/brief_report.md"
```
"""
function mdpaths(fnameexpr, strvec::Vector, this_dir)
    fldrexpr = result_folder_expr(strvec)
    return _mdpaths(fnameexpr, fldrexpr, this_dir)
    # expr = result_folder_expr(strvec)
    # targetdirs = folderlist(expr, this_dir)
end

"""
`mdpaths(fnameexpr, fldrexpr::Regex, this_dir)` returns a list of paths to the markdown files who matches `fnameexpr`.
It searches only the markdown files in the folders in `this_dir` whose name matches `fldrexpr`.
"""
function mdpaths(fnameexpr, fldrexpr::Regex, this_dir)
return _mdpaths(fnameexpr, fldrexpr, this_dir)
end

function _mdpaths(fnameexpr::Regex, fldrexpr, this_dir::AbstractString)
    vcat(filelist.(fnameexpr, folderlist(fldrexpr, this_dir))...)
    # vcat(filelist.(fnameexpr, folderlist(result_folder_expr(strvec), this_dir))...) # for example
end

"""
For `smd::SubMD`,
`SWCForecast.merge!(smd0::SubMD, smds::SubMD...)` merge (using `push!`) the `smd.md.content`,`smd.header`, `smd.hash4`, `smd.path` into `smd0`.

All `smd` in `smds`

# Example
```julia
combinedmd = merge!(SubMD(), smds...)
```
"""
function SWCForecast.merge!(smd0::SubMD, smds::SubMD...)
    for smd in smds
        push!(smd0.md.content, smd.md.content...)
        push!(smd0.header, smd.header...)
        push!(smd0.hash4, smd.hash4...)
        push!(smd0.path, smd.path...)
    end
    return smd0
end

"""
`SWCForecast.merge!(md0::Markdown.MD, mds::Markdown.MD...)`
"""
function SWCForecast.merge!(md0::Markdown.MD, mds::Markdown.MD...)
    for md in mds
        push!(md0.content, md.content...)
    end
    return md0
end

"""
`SWCForecast.merge!(md0::Markdown.MD, contents::Vector...)`

# Example
```julia
md1 = md\"\"\"
# MyTitle with **Bold** string
A paragraph starts here
\"\"\"

contents = [
    Markdown.Header{1}(["Comparison"]),
    Markdown.Paragraph(
        ["This is the comparision of the section ",
        Markdown.Bold(md1.content[1].text), # `MyTitle with **Bold** string`
        " between results."])
]

preface = merge!(md"", contents)
```

which returns the following

# Comparison
This is the comparision of the section MyTitle with **Bold** string between results.
"""
function SWCForecast.merge!(md0::Markdown.MD, contents::Vector...)
    push!(md0.content, contents...)
    return md0
end

function appendheader!(md::Markdown.MD, hash4)
    push!(md.content[1].text, " ($hash4)")
end

function appendheader!(smd::SubMD)
    appendheader!(smd.md, smd.hash4[1])
end


"""
Given a vector of Markdown contents `mdc`, `mdimgpath!(mdc::Vector, dirnm)` recursively searches `Markdown.Image` object and join the url (`Markdown.Image.url`) with `dirnm` (e.g., ).

# Example
Before:
```julia
6-element Vector{Any}:
 Markdown.Header{2}(Any["Result"])
 Markdown.Header{3}(Any["Performance－Tree Depth"])
 Markdown.Paragraph(Any[Markdown.Image("tuned_max_depth.png", "")])
 Markdown.Header{3}(Any["Predict Result"])
 Markdown.List(Any[Any[Markdown.Paragraph(Any["Best maximum depth is 33."])]], -1, false)
 Markdown.Paragraph(Any[Markdown.Image("predict_result.png", "")])
```

Change the url:
```julia
julia> mdimgpath!(md.content, "RESULT_ExpeDeci_0x15b03b01222fec37")
```

After:
```julia

julia> md.content
6-element Vector{Any}:
 Markdown.Header{2}(Any["Result"])
 Markdown.Header{3}(Any["Performance－Tree Depth"])
 Markdown.Paragraph(Any[Markdown.Image("RESULT_ExpeDeci_0x15b03b01222fec37/tuned_max_depth.png", "")])
 Markdown.Header{3}(Any["Predict Result"])
 Markdown.List(Any[Any[Markdown.Paragraph(Any["Best maximum depth is 33."])]], -1, false)
 Markdown.Paragraph(Any[Markdown.Image("RESULT_ExpeDeci_0x15b03b01222fec37/predict_result.png", "")])
```

"""
function mdimgpath!(mdc::Vector, dirnm)
    for obj in mdc
        v = returnchild(obj)
        mdimgpath!(v, dirnm)
    end
end

"""
`mdimgpath!(mdimg::Markdown.Image, dirnm)` modify `mdimg.url` that `mdimg.url = joinpath(dirnm, mdimg.url)`.
"""
function mdimgpath!(mdimg::Markdown.Image, dirnm::AbstractString)
    mdimg.url = joinpath(dirnm, mdimg.url) # add parent directory
    # For example, it makes "tuned_max_depth.png" to "RESULT_ExpeDeci_0x15b03b01222fec37/tuned_max_depth.png".
end

"""
`mdimgpath!(mdimg::Markdown.Image, dirfun::Function)` modify `mdimg.url` that `mdimg.url = dirfun(mdimg.url)`.

# Example
```julia
thatresultdir(args...) = joinpath("foo", "bar", args...)
md1 = md\"\"\"
# Hello
this is a image:
![](foobar.png)
\"\"\"

mdimgpath!(md1.content, thatresultdir)

```
returns

```
md1 = md\"\"\"
# Hello
this is a image:
![](foo/bar/foobar.png)
\"\"\"
```

"""
function mdimgpath!(mdimg::Markdown.Image, dirfun::Function)
    mdimg.url = dirfun(mdimg.url)
end

function mdimgpath!(otherwise, dirnm)
    # if the returned object is not a Vector or Markdown.Image, do nothing
end

"""
`mdimgpath!(smd::SubMD, dirnm) = mdimgpath!(smd.md.content, dirnm)`
"""
function mdimgpath!(smd::SubMD, dirnm)
    mdimgpath!(smd.md.content, dirnm)
end

"""
`mdimgpath!(md::Markdown.MD, dirnm) = mdimgpath!(md.content, dirnm)`
"""
function mdimgpath!(md::Markdown.MD, dirnm)
    mdimgpath!(md.content, dirnm)
end

"""
`returnchild(obj)`:
Given an object `obj::Union{Markdown.Italic, Markdown.Bold, Markdown.Header}`, return the vector `obj.text`.
"""
function returnchild(obj::Union{Markdown.Italic, Markdown.Bold, Markdown.Header})
    return obj.text # a vector of Any
end

"""
`returnchild(obj::Markdown.Paragraph)`:
Given a `Markdown.Paragraph`, return the vector `obj.text`.
"""
function returnchild(obj::Markdown.Paragraph)
    return obj.content # a vector of Any
end

function returnchild(obj::Markdown.Code)
    return obj.code # text string
end

function returnchild(obj::Markdown.List)
    return obj.items # Vector
end

function returnchild(obj)
    return obj # obj might be a Vector or Markdown.Image or Anything.
end


function copyimg(mdc::Vector, srcfun, destfun)
    for obj in mdc
        v = returnchild(obj)
        copyimg(v, srcfun, destfun)
    end
end

"""
Copy images that are referenced in the markdown script `md` to destinations.
"""
function copyimg(md::Markdown.MD, srcfun, destfun)
    mdc = md.content
    copyimg(mdc, srcfun, destfun)
end

function copyimg(mdimg::Markdown.Image, srcfun, destfun)
    dest = destfun(mdimg.url)
    sourceimg = srcfun(mdimg.url)

    targetdir = dirname(dest)
    if !isdir(targetdir)
        mkpath(targetdir)
    end

    if !isfile(sourceimg)
        @warn "$sourceimg does not exist. The results will have missing image references."
        return nothing
    end

    cp(sourceimg, dest; force=true)
end

function copyimg(otherwise, srcfun, destfun)
    # if the returned object is not a Vector or Markdown.Image, do nothing
end
