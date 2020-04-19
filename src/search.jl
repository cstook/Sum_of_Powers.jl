struct Best end # best e for all combinations of a_k

function search(s::Integer,n::Integer,::Best)
    a_k = Array{Int}(1:s-1)
    a_k_to_n = Array{BigInt}(BigInt.(a_k).^n)
    lhs = BigInt(s)^n
    best_error = BigInt(lhs)
    best_combination = 0
    for combination in 1:2^length(a_k)-1
        error = BigInt(lhs)
        for i in OnePositions(combination)
            error-=a_k_to_n[i]
        end
        if abs(error) < abs(best_error)
            best_error = error
            best_combination = combination
        end
    end
    (collect(OnePositions(best_combination)),best_error)
end
