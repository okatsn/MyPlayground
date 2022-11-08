using SWCForecast
using Documenter

DocMeta.setdocmeta!(SWCForecast, :DocTestSetup, :(using SWCForecast); recursive=true)

makedocs(;
    modules=[SWCForecast],
    authors="okatsn <okatsn@gmail.com> and contributors",
    repo="https://github.com/okatsn/SWCForecast.jl/blob/{commit}{path}#{line}",
    sitename="SWCForecast.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://okatsn.github.io/SWCForecast.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/okatsn/SWCForecast.jl",
    devbranch="main",
)
