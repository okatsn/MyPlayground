using PkgTemplates
t = Template(;
    user="okatsn",
    dir=joinpath(pwd(),"PkgLocation4Test"),
    julia=v"1.6",
    plugins=[
        Git(; manifest=false),
        GitHubActions(),
        Codecov(), # https://about.codecov.io/
        Coveralls(), # https://coveralls.io/
        Documenter{GitHubActions}(),
    ],
    pages=[
        "Home" => "index.md",
        "Examples" => "examples/examples.md",
        "Exported Functions" => "functions.md",
        "Models" =>
                    ["Model 1" => "models/model1.md",
                     "Model 2" => "models/model2.md"],
        "Reference" => "reference.md",
    ] # https://documenter.juliadocs.org/stable/man/guide/#Adding-Some-Docstrings
) # https://www.juliabloggers.com/tips-and-tricks-to-register-your-first-julia-package/


# t = Template(;user="okatsn", plugins = [GitHubActions(), Codecov()])
t("SWCForecast.jl")

# Connect to remote:
# 1. Switch to the local directory "SWCForecast"
# 2. Add an empty repo "SWCForecast.jl" on github (without anything!)
# 3. `git push origin main`
#
# It can be quite tricky, see
# - https://discourse.julialang.org/t/upload-new-package-to-github/56783





# More reading
# Pkg's Artifact that manage an external dataset as a package
# - https://pkgdocs.julialang.org/v1/artifacts/
# - a provider for reposit data: https://github.com/sdobber/FA_data
