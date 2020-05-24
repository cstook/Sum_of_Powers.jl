function binary_search_fix_overlap_random(k_max, n, k_random,
                                    tn=a_to_n(k_max+1,n),
                                    ctn=cumulative_a_to_n(k_max+1, n, tn),
                                    target_value=tn[k_max+1])
    # find binary representation of right hand side, rhs_b, and error
    # closest to target value
    k = k_max
    current_target_value = target_value
    one_at_k = BigInt(1)<<(k_max-1) # start with a one in k_max position
    rhs_b = BigInt(0)
    e = BigInt(1)
    while k>1
        is_tn_over = tn[k]>current_target_value # ex 1000
        is_ctn_over = ctn[k-1]>current_target_value # ex 0111
        if is_tn_over & ~is_ctn_over
            # we are done.  pick lower error and return
            e_tn = current_target_value - tn[k]
            e_ctn = current_target_value - ctn[k-1]
            if abs(e_tn)<abs(e_ctn)
                rhs_b = rhs_b | one_at_k
                return rhs_b, e_tn
            else
                rhs_b = rhs_b | one_at_k-1
                return rhs_b, e_ctn
            end
        end
        if is_tn_over & is_ctn_over
            # msb is 0.  set to 0 (reset) and move to next bit.
            # nothing to do here ?
        elseif ~is_tn_over & ~is_ctn_over
            # msb is 1. set to one and move to next bit.
            current_target_value -= tn[k]
            rhs_b = rhs_b|one_at_k
        else # ~is_tn_over & is_ctn_over
            # recursive call with msb 1 and 0.  pick lower error
            if k>k_random # unless k is big
                if rand(Bool)
                    current_target_value -= tn[k]
                    rhs_b = rhs_b|one_at_k
                end
            else
                rhs_b_1,e_1 = binary_search_fix_overlap_random(k-1,n,k_random,tn,ctn,current_target_value-tn[k])
                rhs_b_0,e_0 = binary_search_fix_overlap_random(k-1,n,k_random,tn,ctn,current_target_value)
                if abs(e_1)<abs(e_0)
                    rhs_b = rhs_b | rhs_b_1 |one_at_k
                    return rhs_b,e_1
                else
                    rhs_b = rhs_b | rhs_b_0
                    return rhs_b,e_0
                end
            end
        end
        e==0 && return rhs_b,e
        k-=1
        one_at_k>>=1
    end
    rhs_b|1, current_target_value-1
end
