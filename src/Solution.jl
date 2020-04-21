
# s^n = sum(a.^n) + error
struct Solution{T<:Integer,N}
    s :: T
    n :: Int
    a :: NTuple{N,T}
    function Solution(s::T,n::Int,a,AZsPC::Bool=true) where {T<:Integer}
        N = length(a)
        @assert N<s
        if AZsPC
            @assert N>1
            @assert n>15
            @assert n<41
        end
        for x in a
            @assert x<s
        end
        sorted_a=sort([a...])
        @assert allunique(sorted_a)
        new{T,N}(s,n,Tuple(sorted_a))
    end
end
Base.show(io::IO, x::Solution) = print(io,string(x))
function Base.string(sol::Solution,witherror::Bool= false)
    to_string((sol.s,sol.n,sol.a),witherror)
end
function to_string(x,witherror::Bool=false)
    s,n,a = x
    out = string(s,"^",n,"=>{",a[1])
    for value in a[2:end]
        out = out*string(",",value)
    end
    out = out*"}"
    if witherror
        out = out*",e="*string(err(s,n,a))
    end
    out
end
function err(sol::Solution, acc=BigInt(0))
    err((sol.s,sol.n,sol.a),acc)
end
function err(x, acc=BigInt(0))
    s,n,a = x
    acc = acc + BigInt(s)^n
    for ak in a
        acc = acc - BigInt(ak)^n
    end
    acc
end


function f()
    # 28^16=>{27,26,24,23,20,19,18,17},e=-3923372792424650116
    s = 28
    n = 16
    a = Vector{Int}()
    for i in 19:-1:1
        ss =SubSet([x for x in (i+8):-1:i])
        best_a, e = search(s,n,a,ss)
        @show Solution(s,n,best_a,false)
        @show e
        a = best_a
    end
end
