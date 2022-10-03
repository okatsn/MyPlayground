"""
Providing the `paths` to csv files, `filecolumnview(paths)` gives a plot indicating the available columns of each file.
"""
function filecolumnview(paths; aspect=15, resolution = (2000,900))
    df, dfi = isvarexist(paths)
    pts = Point.(dfi.varname, dfi.fname)
    markers = Char[categorical(df.isexist)...]

    f = Figure(resolution=resolution)
    ax = Axis(f[1, 1] #, yreversed = true,
    #   xautolimitmargin = (0.15, 0.15),
    #   yautolimitmargin = (0.15, 0.15)
    )
    scatter!(ax, pts; marker = markers, markersize=20)
    nvar = length(levels(df.varname))
    nfnm = length(levels(df.fname))
    ax.xticks = (1:nvar, levels(df.varname))
    ax.yticks = (1:nfnm, levels(df.fname))
    ax.xticklabelrotation = pi/2
    xlims!(0, nvar + 1)
    ylims!(0, nfnm + 1)
    ax.aspect = aspect
    f
    return (ax, f)
end

"""
Given a directory `dir`, `filecolumnview(fexpr::Regex, dir)` gives a plot indicating the available columns in files under `dir` that matches `fexpr`.
"""
function filecolumnview(fexpr::Regex, dir)
    paths = filelist(fexpr, dir)
    filecolumnview(paths)
end

"""
`isvarexist(paths)` returns dataframes `(df1, df2)` in the "long" format with each row indicating whether a variable in a file exists.
In which, `(df, dfi)` both have columns `[:varname, :fname, :isexist]`.
In `df`, all variables are `CategoricalArray`s; in `dfi`, all variables are integers for indexing `levels(df.varname)`, `levels(df.fname)` and `levels(df.isexist)`.
"""
function isvarexist(paths)
    (ks, vls) = getallfeat(paths) # all features (one vector one file)
    return isvarexist(ks, vls)
end

function isvarexist(ks, vls)
    # todo: write test for this
    allfeats = union(vls...)
    df_isvar = DataFrame(:varname => allfeats)
    for (k,v) in zip(ks, vls)
        insertcols!(df_isvar, k => in.(allfeats, [v]))
    end

    df2 = select(df_isvar, :varname, AsTable(Not(:varname)) => ByRow(nt -> map(x -> (x ? '✓' : '❌'),nt)) => AsTable)
    df2 = stack(df2, Not(:varname), [:varname]; variable_name=:fname, value_name=:isexist) # stack against all variable names, with the old column names the new column `:fname`, and transform `true` or `false` to emoji indicating whether a column exists in a file being the new column `:isexist`.
    df3 = select(df2, AsTable(:) => (nt -> map(var -> categorical(var; ordered=true), nt)) => AsTable) # let all variables be categorical array; `ordered=true` is important for indexing.

    df3ind = select(df3, AsTable(:) => (nt -> map(x -> x.refs, nt)) => AsTable) # the paralell table for indexing
    return (df3, df3ind)
end


# x = CategoricalArray(["Old", "Young", "Middle", "Young"], ordered=true)
# levels(x)
# isordered(x)
# levels!(x, ["Young", "Middle", "Old"])
# levels(x)


"""
Get all features (column names). Returns file names (`ks`) and columnames of each file (`vls`).
"""
function getallfeat(paths::Vector)
    ks = String[]
    vls = []
    for path in paths
        push!(ks, basename(path))
        push!(vls,  getallfeat(path))
    end
    return (ks, vls)
end

"""
Get all features (a vector of column names).
"""
function getallfeat(path::AbstractString)
    df = CSV.read(path, DataFrame)
    dffeat = df |> names
end
