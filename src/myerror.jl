"""
# Example
```julia
if not_expected
    throw(NoCorrespondingFile("0 file(s) are found. There should be exactly only one file."))
end
```

"""

struct DifferentContent <: Exception
    var::String
end

FS_FrictionExperiment.showerror(io::IO, e::DifferentContent) = print(io, e.var)
