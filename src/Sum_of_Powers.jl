module Sum_of_Powers
import Base.string
import Combinatorics.combinations
using Plots

export Solution, err, best, print_best, print_best_to_file

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
function best_old(s,n,powers=powers_tuple(s,n))
    s_to_n = s^(BigInt(n))
    best_e = s_to_n
    best_c = Array{Int,1}[]
    for c = combinations(s-1:-1:1)
        e = s_to_n
        for i in c
            e = e - powers[s-i]
        end
        if abs(e)<best_e
            best_e = e
            best_c = c
        end
    end
    Solution(s,n,best_c),best_e
end
function best(s,n,powers=powers_tuple(s,n))
    s_to_n = s^(BigInt(n))
    best_e = s_to_n
    best_c = Array{Int,1}[]
    if s>3
        comb = combinations(s-2:-1:2)
    else
        best_c = collect(s-1:-1:1)
        sol = Solution(s,n,best_c)
        best_e = err(sol,0)
        return sol,best_e
    end
    for c = comb
        pushfirst!(c,s-1)
        e = s_to_n
        for i in c
            e = e - powers[s-i]
        end
        if abs(e)<best_e
            best_e = e
            best_c = c
        end
    end
    if best_e>0
        push!(best_c,1)
        best_e = best_e-1
    end
    return Solution(s,n,best_c),best_e
end

function print_best(io::IO,s,n,powers=powers_tuple(s,n))
    sol,e = best(s,n,powers)
    println(io,string(sol),",e=",string(e))
end

function print_best_to_file(s_start,s_stop,n,file="data/n$(n)best.txt")
    open(file,"a") do io
        for s in s_start:s_stop
            print_best(io,s,n)
            flush(io)
        end
    end
end







function ns()
    n = 2:17
    s = [4,5,7,8,10,11,12,14,15,17,18,20,21,23,24,26]
    n,s
end


end # module
