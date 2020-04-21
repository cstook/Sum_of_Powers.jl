struct Best end # best e for all combinations of a_k

# best e for all combinations of subset of a_k's at positions of ones in c
struct SubSet{T<:Integer}
    c :: T      # subset to optimize
end

function search(s::Integer,n::Integer,::Best)
    a_k = Array{Int}(1:s-1)
    a_k_to_n = Array{BigInt}(BigInt.(a_k).^n)
    lhs = BigInt(s)^n
    bc,best_error = best_combination(a_k_to_n, lhs)
    collect(OnePositions(bc)),best_error
end

function search(s::T, n::Integer, initial_a_k::T, ss::SubSet{T}) where {T<:Integer}
    @assert count_ones(initial_a_k)==s-1
    s_to_n = BigInt(s)^n
    lhs = s_to_n
    not_ss = not_subset(ss.c)
    for i in  insersect(OnePositions(not_ss),OnePositions(initial_a_k))
        lhs-=a_k^n
    end
    bc_subset,best_error = best_combination(a_k_to_n_in_subset(ss,s-1), lhs)
    x = collect(OnePositions(ss.c))
    y = Vector{T}()
    sizehint!(y,count_ones(bc_subset))
    for i in OnePositions(bc_subset)
        push!(y,x[i])
    end
    union(y,OnePositions(not_ss)), best_error
end

function best_combination(a_k_to_n,
                          lhs::BigInt,
                          best_error::BigInt = BigInt(lhs)
                          )
    bc = 0
    for combination in 1:2^length(a_k_to_n)-1
        error = BigInt(lhs)
        for i in OnePositions(combination)
            error-=a_k_to_n[i]
        end
        if abs(error) < abs(best_error)
            best_error = error
            bc = combination
        end
    end
    bc,best_error
end

function a_k_to_n_in_subset(ss:SubSet{T},n) where {T<:Integer}
    a_k_to_n = Vector{BigInt}()
    sizehint!(a_k_to_n,count_ones(ss.c))
    for i in OnePositions(ss.c)
        push!(a_k_to_n,BigInt(i^n))
    end
    a_k_to_n
end
function not_subset(ss::SubSet{T}, number_of_bits) where {T<:Integer}
    enough_ones = T(2)^(number_of_bits+1)-1
    enough_ones ⊻ ss.c
end
