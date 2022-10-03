"""
Praise master ZK!
`print2string(printfun)` print content to memory and take it out as a `String`.

# Example
```
printfun() = MLJDecisionTreeInterface.DT.print_tree(
    mach.fitresult.fitresult; feature_names=names(mach.fitresult.data[1]))

print2string(printfun)
```

"""
function print2string(printfun)
    iotemp = IOBuffer()
    myshow(iotemp) do
        printfun()
    end
    return String(take!(iotemp))
end

function myshow(f::Function, io::IO)
    old_stdout = stdout
    rd, = redirect_stdout()
    task = @async Base.write(io, rd)
    try
        ret = f()
        Libc.flush_cstdio()
        flush(stdout)
        return ret
    finally
        close(rd)
        redirect_stdout(old_stdout)
        wait(task)
    end
end
