# olny look for zeros


struct CommonThings
    tn :: Vector{BigInt}
    ctn :: Vector{BigInt}
    max_k :: Int
    n :: Int
    fpt :: Int
end
function common_things(max_k, n)
    tn = a_to_n(max_k, n)
    ctn = cumulative_a_to_n(max_k, n, tn)
    fpt = first_problem_term(max_k, n, tn, ctn)
    CommonThings(tn,ctn,max_k,n,fpt)
end

# return a rhs_b for zero or nothing
function look_for_zero(s, ct::CommonThings)
    one_at_k = BigInt(1)<<(max_k-1) # start with a one in max_k position
    target = ct.tn[s]
    rhs_b = BigInt(0)
    above_split(s-1,one_at_k,target,rhs_b,ct)
end
function above_split(k, one_at_k::BigInt, target::BigInt, rhs_b::BigInt, ct::CommonThings)
    target<0 && return nothing
    target>ct.ctn[k] && return nothing # k-1 ?
    k<ct.fpt && return below_split(k, one_at_k, target_rhs_b, ct)
    rhs_b_one  = above_split(k-1,one_at_k>>1,target-ct.tn[k],rhs_b|one_at_k,ct)
    ~isnothing(rhs_b_one) && return rhs_b_one
    rhs_b_zero = above_split(k-1,one_at_k>>1,target,rhs_b,ct)
    ~isnothing(rhs_b_zero) && return rhs_b_zero
    nothing
end
function below_split(k, one_at_k::BigInt, target::BigInt, rhs_b::BigInt, ct::CommonThings)
    for i in k:-1:1
        
    end
end
