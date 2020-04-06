module Sum_of_Powers
using Primes
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

s = Solution(15,4,(14,9,8,6,3))
string(s)

end # module
