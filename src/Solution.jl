
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

function Base.parse(::Type{Solution}, s::AbstractString, AZsPC::Bool=true)
    m = match(r"\s*(\d*)\s*\^\s*(\d*)\s*=>\s*\{([0-9, ]+)\}",s)
    isnothing(m) && return nothing
    s = parse(Int,m.captures[1])
    n = parse(Int,m.captures[2])
    a_string = m.captures[3]
    pos = 1
    a = Vector{Int}()
    while true
        next_pos = findnext(isequal(','),a_string,pos)
        if isnothing(next_pos)
            a_k = parse(Int,a_string[pos:end])
            push!(a,a_k)
            break
        else
            a_k = parse(Int,a_string[pos:prevind(a_string,next_pos)])
            push!(a,a_k)
        end
        pos = nextind(a_string, next_pos)
    end
    Solution(s,n,a,AZsPC)
end
