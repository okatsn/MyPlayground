using Pkg

mypkglist = [
    "https://github.com/okatsn/DataFrameTools.jl.git#main",
    "https://github.com/okatsn/FileTools.jl#master",
    "https://github.com/okatsn/Shorthands.jl.git#master",
    "https://github.com/okatsn/HypertextTools.jl.git#master"
]

# TODO: remove current personal developed packages; add registry and add those packages again.
for myurl in mypkglist
    Pkg.add(url=myurl)
end
