struct Best end # best e for all combinations of a_k

function search(s::Integer,n::Integer,::Best)
    a_k = 1:s-1
    a_k_to_n = Tuple(BigInt.(a_k).^n)
    lhs = BigInt(s)^n
    best_error = lhs
    best_combination = 0
    for combination in 1:2^length(a_k)-1
        error = lhs
        for op in OnePositions(combination)
            error-=a_k_to_n[op]
        end
        if abs(error) < abs(best_error)
            best_error = error
            best_combination = combination
        end
    end
    (collect(OnePositions(best_combination)),best_error)
end
