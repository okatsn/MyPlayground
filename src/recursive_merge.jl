"""
`recursive_merge` merges dictionaries combining thier unique key-value pairs together.
Similar to `merge(d, d1, d2,...)`, but `recursive_merge` merge the dictionary recursively that sub-dictionaries are also merged, while `merge(d, d1)` replace the sub-dict in `d` by that in `d1`.
This piece of code originally came from this thread:
https://discourse.julialang.org/t/multi-layer-dict-merge/27261/2
"""
recursive_merge(x::AbstractDict...) = merge(recursive_merge, x...)

"""
See `recursive_merge`.
"""
recursive_merge!(x::AbstractDict...) = merge!(recursive_merge, x...)
