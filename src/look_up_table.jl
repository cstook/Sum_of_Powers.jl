a_to_n(max_k, n) = [BigInt(x)^n for x in 1:max_k]
function cumulative_a_to_n(max_k, n, to_n=a_to_n(max_k,n))
    x = Vector{BigInt}(undef,max_k)
    y = BigInt(0)
    for k in 1:max_k
        y += to_n[k]
        x[k] = y
    end
    x
end
function problem_terms(max_k, n, to_n=a_to_n(max_k,n), ctn=cumulative_a_to_n(max_k, n, to_n))
    x = Vector{Int}()
    y = Vector{BigInt}()
    for k in 2:max_k
        lhs = to_n[k]-ctn[k-1]
        if lhs<0
            push!(x,k)
            push!(y,lhs)
        end
    end
    x, y
end
function drop_terms(max_k, n, to_n=a_to_n(max_k,n))
    dt = Vector{Int}() # dropped terms
    it = Vector{Int}() # included terms
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


struct RHS<:AbstractArray{BigInt,1}
    a_to_n :: Vector{BigInt}
end
Base.size(rhs::RHS) = (2^(length(rhs.a_to_n))-1,)
Base.IndexStyle(::RHS) = IndexLinear()
Base.setindex!(::RHS,v,i::Int) = throw(ErrorException("type RHS not writeable"))
Base.getindex(rhs::RHS, i::Int) = sum(rhs.a_to_n[OnePositions(i)])

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

function sorted_up_to(bits::Int, n::Int)
    to_n = [BigInt(x)^n for x in 1:bits]
    table_length = 2^bits-1
    previous_sum = BigInt(0)
    for a in 1:table_length
        new_sum= sum(to_n[OnePositions(a)])
        new_sum < previous_sum && return a
        previous_sum = new_sum
    end
    return table_length
end

isallsorted(bits,n) = sorted_up_to(bits,n)==2^bits-1



#=
y = [3.0,4.0,5.0,7.0,8.0,10.0,11.0,13.0,14.0,15.0,17.0,18.0,20.0,21.0,23.0,24.0,26.0,27.0,28.0]

#first 0
n = [5, 6, 7, 9, 10]
s = [12,25,40,49,63]
=#
