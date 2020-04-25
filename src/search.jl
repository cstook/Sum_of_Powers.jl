struct Best end # best e for all combinations of a_k

# best e for all combinations of subset of a_k's at positions of ones in c
struct SubSet{T<:Integer}
    a::Vector{T}      # subset to optimize
end

struct SlidingWindow
    width :: Int
end

struct MabeyBest end # optimized version of Best

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

function search(::MabeyBest, s::Int, n::Int, ::Vector{Int}=[])
    all_a_to_n = [BigInt(x)^n for x in 1:s-1]
    lhs = BigInt(s)^n
    select_a = falses(s-1)

    _mabey_best!(lhs,s-1,all_a_to_n)
end
function _mabey_best!(lhs::BigInt, max_k::Int,  all_a_to_n::Vector{BigInt})
    split = find_split(lhs, max_k, all_a_to_n)
    view_a_to_n = view(all_a_to_n,split-1:1)
    for upper_combinations in OnePositions(2^(max_k-split+1))
        new_lhs = lhs-sum(view_a_to_n[upper_combinations])
        _mabey_best(new_lhs, split-1, view_a_to_n)
    end
end
function find_split(lhs::BigInt, max_k::Int, all_a_to_n::BigInt)::Int
    e = lhs
    for k in 1:max_k
        e-=all_a_to_n[k]
        e<=0 && return k
    end
    return max_k
end

function max_s_for_all_a(n)
    s = 1
    old_s_to_n = BigInt(1)
    e = old_s_to_n
    while true
        s+=1
        new_s_to_n = BigInt(s)^n
        e = e + new_s_to_n - 2*old_s_to_n
        e<0 && return s-1
        old_s_to_n = new_s_to_n
    end
end
