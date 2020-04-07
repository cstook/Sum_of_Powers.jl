module Sum_of_Powers
import Base.string

struct Solution{T<:Integer,N}
    s :: T
    n :: Int
    a :: NTuple{N,T}
end

function Base.string(s::Solution)
    out = string(s.s,"^",s.n,"=>{",s.a[1])
    for value in s.a[2:end]
        out = out*string(",",value)
    end
    out = out*"}"
    out
end

function err(sol::Solution, acc=BigInt(0))
    acc = acc + sol.s^s.n
    for a in sol.a
        acc = acc - a^s.n
    end
    acc
end

end # module
