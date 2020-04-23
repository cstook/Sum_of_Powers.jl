struct Best end # best e for all combinations of a_k

# best e for all combinations of subset of a_k's at positions of ones in c
struct SubSet{T<:Integer}
    a::Vector{T}      # subset to optimize
end

struct SlidingWindow
    width :: Int
end

function search(::Best,s::Integer,n::Integer,::Vector=[])
    a = Array{Int}(1:s-1)
    a_to_n = Array{BigInt}(BigInt.(a).^n)
    lhs = BigInt(s)^n
    bc,best_error = best_combination(a_to_n, lhs)
    collect(OnePositions(bc)),best_error
end

function search(ss::SubSet{T}, s::T, n::Integer, a::Vector{T}) where {T<:Integer}
    @assert length(a)<s
    lhs =  BigInt(s)^n
    a_not_in_subset = setdiff(a,ss.a)
    for a_k in a_not_in_subset
        lhs-=BigInt(a_k)^n
    end
    bc_subset,best_error = best_combination([BigInt(x)^n for x in ss.a], lhs)
    best_a = a_not_in_subset
    sizehint!(best_a,length(best_a)+count_ones(bc_subset))
    for k in OnePositions(bc_subset)
        push!(best_a,ss.a[k])
    end
    best_a, best_error
end

function search(sw::SlidingWindow, s::Int, n::Int, a::Vector{Int})
    window_max = s-1
    window_min = s-1-sw.width
    ss = SubSet([x for x in window_max:-1:window_min])
    e = BigInt(0)
    for i in 1:window_min
        a,e = search(ss,s,n,a)
        ss.a.-=1
    end
    a,e
end

function best_combination(a_to_n,
                          lhs::BigInt,
                          best_error::BigInt = BigInt(lhs)
                          )
    bc = 0
    for combination in 1:2^length(a_to_n)-1
        error = BigInt(lhs)
        for k in OnePositions(combination)
            error-=a_to_n[k]
        end
        if abs(error) < abs(best_error)
            best_error = error
            bc = combination
        end
    end
    bc,best_error
end



powers_tuple_old(s,n) = ntuple(x->(s-x)^BigInt(n),s-1)
function max_all_a(n)
    s=2
    while true
        powers=powers_tuple_old(s,n)
        all = collect(s-1:-1:1)
        e = s^(BigInt(n))
        for i in all
            e = e - powers[s-i]
        end
        if e<0
            return s-1
        end
        s+=1
    end
end
