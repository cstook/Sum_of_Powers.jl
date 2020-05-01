struct Best end # best e for all combinations of a_k

# best e for all combinations of subset of a_k's at positions of ones in c
struct SubSet{T<:Integer}
    a::Vector{T}      # subset to optimize
end

struct SlidingWindow
    width :: Int
end

struct MabeyBest end # optimized version of Best
struct IncludedTerms end

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

function search(::MabeyBest, s::Int, n::Int, ::Vector{Int}=Vector{Int}([]))
    max_k = s-1
    all_a_to_n = [BigInt(x)^n for x in 1:max_k]
    lhs = BigInt(s)^n
    select_a = if max_k<65
        UInt64(0)
    elseif max_k<129
        UInt128(0)
    else
        BigInt(0)
    end
    best = Tracker(select_a,lhs)
    _mabey_best!(select_a, best, lhs, max_k, all_a_to_n)
    best_a, best_error = best()
    Int.(collect(OnePositions(best_a))), best_error
end
function _mabey_best!(select_a::T, best::Tracker, lhs::BigInt, max_k::Int, all_a_to_n) where T<:Integer
    # select_a and best are modified
    is_error_zero(best) && return nothing
    if max_k == 0
        best(select_a, lhs)
        return nothing
    end
    split,e = find_split(lhs, max_k, all_a_to_n)
    all_ones_to_split = select_a | T(2)^(split-1)-1
    best(all_ones_to_split, e)
    split-1==max_k && return nothing
    upper_view_a_to_n = view(all_a_to_n, split:max_k)
    lower_view_a_to_n = view(all_a_to_n, 1:split-1)
    upper_combination_range = 1:T(2)^(max_k-split+1)-1
    for upper_combination in upper_combination_range
        new_select_a = select_a ⊻ upper_combination<<(split-1)
        new_lhs = lhs-sum(upper_view_a_to_n[OnePositions(upper_combination)])
        best(new_select_a, new_lhs)
        if new_lhs>0
            _mabey_best!(new_select_a, best, new_lhs, split-1, lower_view_a_to_n)
        end
    end
    nothing
end
function find_split(lhs::BigInt, max_k::Int, all_a_to_n)
    e = lhs
    for k in 1:max_k
        previous_error = e
        e-=all_a_to_n[k]
        e<=0 && return k,previous_error
    end
    return max_k+1,e
end
function true_positions(x::BitArray{1})
    positions = Vector{Int}()
    for i in eachindex(x)
        i[x] && push!(positions,i)
    end
    positions
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

function search(::IncludedTerms, s::Int, n::Int)
    max_k = s-1
    to_n = a_to_n(max_k, n)
    dt,it = drop_terms(max_k, n)
    it_to_n = to_n[it]
    s_to_n = BigInt(s)^n
    # write my own sortedsearch
    #=
    rhs = RHS(it_to_n)
    l = searchsortedfirst(rhs, s_to_n)
    l_error = s_to_n-rhs[l]
    if l<length(rhs)
        h = l+1
        h_error = s_to_n-rhs[h]
        x,best_error = abs(l_error)<abs(h_error) ? (l,l_error) : (h,h_error)
    else
        x,best_error = (l,l_error)
    end
    =#
    # insert zeros for dropped terms
    x,best_error
end
