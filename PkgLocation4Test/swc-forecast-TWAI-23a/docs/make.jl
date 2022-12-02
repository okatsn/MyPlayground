using swc-forecast-TWAI-23a
using Documenter

DocMeta.setdocmeta!(swc-forecast-TWAI-23a, :DocTestSetup, :(using swc-forecast-TWAI-23a); recursive=true)

makedocs(;
    modules=[swc-forecast-TWAI-23a],
    authors="okatsn <okatsn@gmail.com> and contributors",
    repo="https://github.com/okatsn/swc-forecast-TWAI-23a.jl/blob/{commit}{path}#{line}",
    sitename="swc-forecast-TWAI-23a.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://okatsn.github.io/swc-forecast-TWAI-23a.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/okatsn/swc-forecast-TWAI-23a.jl",
    devbranch="main",
)
