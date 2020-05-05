a_to_n(max_k, n) = [BigInt(x)^n for x in 1:max_k]
function cumulative_a_to_n(max_k, n, to_n=a_to_n(max_k,n))
    x = Vector{BigInt}(undef,max_k)
    y = 0
    for k in 1:max_k
        y += to_n[k]
        x[k] = y
    end
    x
end
function problem_terms(max_k, n, to_n=a_to_n(max_k,n), ctn=cumulative_a_to_n(max_k, n, to_n))
    x = Vector{Int}() # problem terms
    y = Vector{BigInt}() # error
    for k in 2:max_k
        e = to_n[k]-ctn[k-1]
        if e<0 # is kth term less than the sum of all previous terms
            push!(x,k)
            push!(y,e)
        end
    end
    x, y
end
function overlap_dict(max_k, n,
                      tn=a_to_n(max_k+1,n),
                      ctn=cumulative_a_to_n(max_k+1, n, tn))
    d = Dict{Int,Tuple{BigInt,BigInt}}()
    for k in 3:max_k
        limits = overlap_limits(max_k, k, n, tn, ctn)
        isnothing(limits) || push!(d,k=>limits)
    end
    d
end
# find the extent of the overlap around k where the binary representation of the a_k's is
# not in order.  Assume no double overlap for now.
function overlap_limits(max_k, k, n,
                        tn=a_to_n(max_k+1,n),
                        ctn=cumulative_a_to_n(max_k+1, n, tn))
    # for lack of better names we will use b,c,d,e
    # b,e will be the limits of the overlap to be found by this function
    # c,d are easy to understand from the code below
    # when we are done b<c<d<e and b,e are the limits of overlap around term k
    k+=1 # OK, I know this is BAD!
    c = tn[k]
    d = ctn[k-1]
    c>=d && return nothing # no overlap
    # find b
    rhs_b_min = BigInt(1)<<(k-2)
    rhs_b_max = (BigInt(1)<<(k-1))-1
    target_value = c
    b = binary_search(max_k,
                     rhs_b_min, rhs_b_max,
                     target_value,
                     n,tn)
    # find e
    rhs_b_min = BigInt(1)<<(k-1)
    rhs_b_max = (BigInt(1)<<k)-1
    target_value = d
    e = binary_search(max_k,
                     rhs_b_min, rhs_b_max,
                     target_value,
                     n,tn) +1
    b,e
end
function binary_search(max_k,
                      rhs_b_min, rhs_b_max,
                      target_value::BigInt,
                      n,
                      tn=a_to_n(max_k,n))
    # return binary representation of rhs adjacent to target value.
    # it will be the rhs below the target value.
    # assumes the rhs value is in the same order as its binary representation.
    rhs_b = BigInt(0)
    previous_rhs_b = BigInt(0)
    rhs_v = BigInt(0)
    e = BigInt(0)
    while true
        previous_rhs_b = rhs_b
        rhs_b = div(rhs_b_min+rhs_b_max,2)
        previous_rhs_b == rhs_b && break
        rhs_v = sum(tn[OnePositions(rhs_b)])
        e = target_value - rhs_v
        e == 0 && break
        e>0 ? (rhs_b_min=rhs_b) : (rhs_b_max=rhs_b)
    end
    if e>0 && iseven(rhs_b)
        rhs_b+=1
        e-=1
    end
    return rhs_b
end

function first_problem_term(max_k, n, to_n=a_to_n(max_k,n), ctn=cumulative_a_to_n(max_k, n, to_n))
    for k in 2:max_k
        e = to_n[k]-ctn[k-1]
        e<0 && return k # is kth term less than the sum of all previous terms
    end
    nothing
end
function drop_terms(max_k, n, to_n=a_to_n(max_k,n)) # this is wrong
    dt = Vector{Int}() # dropped terms
    it = Vector{Int}([1]) # included terms
    cumulative_included_terms = Vector{BigInt}([to_n[1]])
    look_back=1
    for k in 2:max_k
        prev_cit = cumulative_included_terms[k-look_back]
        lhs = to_n[k]- prev_cit
        if lhs<0
            push!(dt,k)
            look_back+=1
        else
            push!(it,k)
            push!(cumulative_included_terms, prev_cit+to_n[k])
        end
    end
    dt, it
end

function insert_zeros(a::T, zero_positions::Array{Int}) where T<:Integer
    zp = sort(zero_positions)
    new_a = a
    mask = T(0)
    for z in zp
        mask = T(2)^(z-1)-1
        lower_bits = mask&new_a
        new_a = ((new_a ⊻ lower_bits)<<1) ⊻ lower_bits
    end
    new_a
end


function issequential(x)
    for i in 2:length(x)
        x[i]-x[i-1] != 1 && return false
    end
    true
end

function create_look_up_table(bits::Int, n::Int)
    to_n = a_to_n(bits,n)
    table_length = 2^bits-1
    sum_combination = Vector{BigInt}(undef,table_length)
    for a in 1:table_length
        sum_combination[a]= sum(to_n[OnePositions(a)])
    end
    #p = sortperm(sum_combination)
    @assert issorted(sum_combination)
    to_n, sum_combination
end

function sorted_up_to(max_k::Int, n::Int)
    to_n = [BigInt(x)^n for x in 1:max_k]
    table_length = 2^max_k-1
    previous_sum = BigInt(0)
    for a in 1:table_length
        new_sum= sum(to_n[OnePositions(a)])
        new_sum < previous_sum && return a
        previous_sum = new_sum
    end
    return table_length
end

isallsorted(max_k,n) = sorted_up_to(max_k,n)==2^max_k-1



#=
y = [3.0,4.0,5.0,7.0,8.0,10.0,11.0,13.0,14.0,15.0,17.0,18.0,20.0,21.0,23.0,24.0,26.0,27.0,28.0]

#first 0
n = [5, 6, 7, 9, 10]
s = [12,25,40,49,63]
=#
