# https://chifi.dev/cool-things-you-can-do-with-vect-in-julia-a4a749068a08

import Base: vect

struct Query
    commands::Vector{Pair{String, String}}
end

struct QueryKeyword{T <: Any} end

const select = QueryKeyword{:select}()

vect(qkw::QueryKeyword{:select}, s::String) = begin
Query(["select" => s])::Query
end


vect(select, "hello")
# which is equivalently:
[select, "hello"]
