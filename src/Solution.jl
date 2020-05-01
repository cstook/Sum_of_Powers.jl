
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

# wrapper for Solution which will show error
struct SolutionError{T<:Integer,N}
    s :: Solution{T,N}
end
Base.show(io::IO, x::SolutionError) = print(io,string(x.s,true))

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
        out = out*",e="*string(err((s,n,a)))
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
    isnothing(m) && throw(ArgumentError("Invalid Solution String"))
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

function parse_solution_error(s::AbstractString, AZsPC::Bool=true)
    m = match(r"(.*})(,\s*e\s*=\s*([0-9+-]*)){0,1}",s)
    isnothing(m) && throw(ArgumentError("Invalid Solution, error String"))
    solution = parse(Solution, m.captures[1], AZsPC)
    if isnothing(m.captures[3])
        e = nothing
    else
        e = parse(BigInt,m.captures[3])
        solution_error = err(solution)
        @assert e == solution_error "string error $e != solution error $solution_error"
    end
    solution, e
end

function raw(x::Solution)
    e = err(x)
    if e==0
        return 1-1/x.s
    else
        return log(abs(e)+1)+1
    end
end
