module Sum_of_Powers
import Base.string
import Combinatorics.combinations
using Plots

export Solution, err, best, write_best

#=
struct Solution{T<:Integer,N}
    s :: T
    n :: Int
    a :: NTuple{N,T}
end
=#

struct Solution{T<:Integer}
    s :: T
    n :: Int
    a :: Array{T,1}
end

function Base.string(sol::Solution)
    out = string(sol.s,"^",sol.n,"=>{",sol.a[1])
    for value in sol.a[2:end]
        out = out*string(",",value)
    end
    out = out*"}"
    out
end

function err(sol::Solution, acc=BigInt(0))
    acc = acc + sol.s^sol.n
    for a in sol.a
        acc = acc - a^sol.n
    end
    acc
end


function improve!(sol::Solution)
    e = err(sol)
    if e<1 return 1 end
    x = round(abs(e)^(1/sol.n))
    newa = rand(1:x-1)
    if newa in sol.a return 2 end
    push!(sol.a,newa)
    return 3
end

powers_tuple(s,n) = ntuple(x->(s-x)^BigInt(n),s-1)
function best(s,n,powers=powers_tuple(s,n))
    s_to_n = s^(BigInt(n))
    best_e = s_to_n
    best_c = Array{Int,1}[]
    for c = combinations(1:s-1)
        e = s_to_n
        for i in c
            e = e - powers[i]
        end
        if abs(e)<best_e
            best_e = e
            best_c = c
        end
    end
    Solution(s,n,best_c),best_e
end

function write_best(io::IO,s,n,powers=powers_tuple(s,n))
    sol,e = best(s,n,powers)
    write(io,string(sol),",e=",e)
end





function ns()
    n = 2:17
    s = [4,5,7,8,10,11,12,14,15,17,18,20,21,23,24,26]
    n,s
end


end # module
