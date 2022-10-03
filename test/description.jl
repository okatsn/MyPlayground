@testset "recursive_merge" begin
    d0 = Dict(
        "Level1a" => [1,2,3],
        "Level1b" => Dict("Level2ba" => "Hello")
        )

    d1 = Dict(
        "Level1b" => Dict("Level2bb" => "World")
    )

    d_01 = Dict(
        "Level1a" => [1, 2, 3],
        "Level1b" => Dict("Level2bb"=>"World", "Level2ba"=>"Hello")
    )

    @test isequal(recursive_merge(d0, d1), d_01)

    d2 = Dict("Level1c" => "My Friend")

    d_012 = Dict(
        "Level1a" => [1, 2, 3],
        "Level1b" => Dict("Level2bb"=>"World", "Level2ba"=>"Hello"),
        "Level1c" => "My Friend"
    )

    @test isequal(recursive_merge(d0, d1, d2), d_012)

    d3 = Dict("Level1a" => Dict("Level2a" => "error expected"))
    # since "Level1a" has already assigned a value which is not a dictionary, thus merging with this entry should return an error.
    ispassed = try
        recursive_merge(d0, d1, d2, d3)
        passed = false # no error
    catch
        passed = true
    end
    @test ispassed

    d4 = Dict(
        "Level1b" => Dict(
            "Level2bc" => Dict(
                "Level3bca" => "How are you?"
            )
        )
    )

    d_0124 = Dict(
        "Level1a" => [1, 2, 3],
        "Level1b" => Dict("Level2bb"=>"World", "Level2ba"=>"Hello",
            "Level2bc" => Dict("Level3bca" => "How are you?")),
        "Level1c" => "My Friend"
    )

    @test isequal(recursive_merge(d_012, d4), d_0124)



end

@testset "description!" begin
    d0 = Dict(
        "Level1a" => [1,2,3],
        "Level1b" => Dict("Level2ba" => "Hello")
        )

    d1 = Dict(
        "Level1b" => Dict("Level2bb" => "World")
    )

    d_01 = Dict(
        "Level1a" => [1, 2, 3],
        "Level1b" => Dict("Level2bb"=>"World", "Level2ba"=>"Hello")
    )

    DDT = DescriptOneTree(projectdir, d0)
    description!(DDT, d1)
    @test isequal(DDT.description, d_01)


    d2 = Dict("Level1c" => "My Friend")
    description!(DDT, d2)

    d_012 = Dict(
        "Level1a" => [1, 2, 3],
        "Level1b" => Dict("Level2bb"=>"World", "Level2ba"=>"Hello"),
        "Level1c" => "My Friend"
    )

    @test isequal(DDT.description, d_012)

    d3 = Dict("Level1a" => Dict("Level2a" => "error expected"))
    # since "Level1a" has already assigned a value which is not a dictionary, thus merging with this entry should return an error.
    ispassed = try
        description!(DDT, d3)
        passed = false # no error
    catch
        passed = true
    end
    @test ispassed

    d4 = Dict(
        "Level1b" => Dict(
            "Level2bc" => Dict(
                "Level3bca" => "How are you?"
            )
        )
    )

    d_0124 = Dict(
        "Level1a" => [1, 2, 3],
        "Level1b" => Dict("Level2bb"=>"World", "Level2ba"=>"Hello",
            "Level2bc" => Dict("Level3bca" => "How are you?")),
        "Level1c" => "My Friend"
    )
    description!(DDT, d4)
    @test isequal(DDT.description, d_0124)



end
