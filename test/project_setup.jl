@testset "project_setup" begin
    @test notebooksdir() == joinpath(dirname(Base.active_project()), "notebooks")

    @test externaldatadir() ==
        joinpath(dirname(Base.active_project()), "data", "0-external")
    @test rawdatadir() == joinpath(dirname(Base.active_project()), "data", "0-raw")
    @test interimdatadir() == joinpath(dirname(Base.active_project()), "data", "1-interim")
    @test finaldatadir() == joinpath(dirname(Base.active_project()), "data", "2-final")

    @test outputdir() == joinpath(dirname(Base.active_project()), "output")
    @test featuresdir() == joinpath(dirname(Base.active_project()), "output", "features")
    @test modelsdir() == joinpath(dirname(Base.active_project()), "output", "models")
    @test reportsdir() == joinpath(dirname(Base.active_project()), "output", "reports")
    @test figuresdir() ==
        joinpath(dirname(Base.active_project()), "output", "reports", "figures")

    @test projectdir() == dirname(Base.active_project())
    @test datadir() == joinpath(dirname(Base.active_project()), "data")
    @test srcdir() == joinpath(dirname(Base.active_project()), "src")
    @test scriptsdir() == joinpath(dirname(Base.active_project()), "scripts")
end
