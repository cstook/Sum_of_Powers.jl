# only look for zeros


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

# return rhs_b for zero or nothing
function look_for_zero(s, ct::CommonThings)
    max_k = s-1
    one_at_k = BigInt(1)<<(max_k-1) # start with a one in max_k position
    target = ct.tn[s]
    rhs_b = BigInt(0)
    above_split(s-1,one_at_k,target,rhs_b,ct)
end
function above_split(k, one_at_k::BigInt, target::BigInt, rhs_b::BigInt, ct::CommonThings)
    target<0 && return nothing
    target>ct.ctn[k] && return nothing # k-1 ?
    k<ct.fpt && return below_split(k, one_at_k, target, rhs_b, ct)
    rhs_b_one  = above_split(k-1,one_at_k>>1,target-ct.tn[k],rhs_b|one_at_k,ct)
    ~isnothing(rhs_b_one) && return rhs_b_one
    rhs_b_zero = above_split(k-1,one_at_k>>1,target,rhs_b,ct)
    ~isnothing(rhs_b_zero) && return rhs_b_zero
    nothing
end
function below_split(k, one_at_k::BigInt, target::BigInt, rhs_b::BigInt, ct::CommonThings)
    for i in k:-1:1
        x = target-ct.tn[i]
        if x>=0
            target = x
            rhs_b = rhs_b | one_at_k
        end
        one_at_k>>=1
    end
    target == 0 && return rhs_b
    nothing
end

function zero_io(io::IO, srange, n, ct)
    @assert 2^n == ct.tn[2]
    for s in srange
      print(io,s," ")
      print("s=",s,"  ")
      @time rhs_b = look_for_zero(s,ct)
      if ~isnothing(rhs_b)
        sol = Solution(s,n,Int.(collect(OnePositions(rhs_b))),false)
        @assert err(sol)==0
        println(io)
        println(io,sol)
      end
      flush(io)
    end
end
