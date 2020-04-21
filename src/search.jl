struct Best end # best e for all combinations of a_k

# best e for all combinations of subset of a_k's at positions of ones in c
struct SubSet{T<:Integer}
    a::Vector{T}      # subset to optimize
end

function search(s::Integer,n::Integer,::Best)
    a_k = Array{Int}(1:s-1)
    a_to_n = Array{BigInt}(BigInt.(a_k).^n)
    lhs = BigInt(s)^n
    bc,best_error = best_combination(a_to_n, lhs)
    collect(OnePositions(bc)),best_error
end

function search(s::T, n::Integer, a::Vector{T}, ss::SubSet{T}) where {T<:Integer}
    @assert length(a)==s-1
    lhs =  BigInt(s)^n
    a_not_in_subset = setdiff(a,ss.a)
    for a_k in a_not_in_subset
        lhs-=a_k^n
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

#=
function a_to_n_in_subset(ss::SubSet{T},n) where {T<:Integer}
    a_to_n = Vector{BigInt}()
    sizehint!(a_to_n,count_ones(ss.c))
    for i in OnePositions(ss.c)
        push!(a_to_n,BigInt(i^n))
    end
    a_to_n
end
function not_subset(ss::SubSet{T}, number_of_bits) where {T<:Integer}
    enough_ones = T(2)^(number_of_bits+1)-1
    enough_ones ⊻ ss.c
end
=#
