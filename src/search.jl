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

function search(s::Integer, n::Integer, a_k, ss::SubSet)

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
