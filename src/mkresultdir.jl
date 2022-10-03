
"""
Given the path to the script file `exp_file`, `mkresultdir` return the path to the new directory named with the hash value of the file. That is, once `exp_file` has been changed, a new directory will be created with its path returned.
"""
function mkresultdir(exp_file; allow_error=false)
# exp_file = trainingdir("decisiontree_20220309","myfunctions.jl")
    fname = basename(exp_file)
    exp_dir = dirname(exp_file)

    strvec = split(splitext(fname)[1], "_")

    for (i,str) in enumerate(strvec)
        strvec[i] = str[1:minimum([4, length(str)])]
    end
    fname_abbr = join(uppercasefirst.(strvec), "");

    result_dir = joinpath(exp_dir, "RESULT"*"_"*fname_abbr*"_"*"0x" * string(hash(read(exp_file, String)); base=16))
    try
        mkdir(result_dir)
    catch e
        @warn e
    end
    exp_resultdir(args...) = projectdir(result_dir, args...)
    return exp_resultdir
end
