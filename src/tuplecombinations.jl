using StaticArrays
using BenchmarkTools

combination(x) = combination_(x...)
combination_(x) = x
combination_(x,y) = (x,y,(x,y))
combination_(x,y...) = (x,combination(y)...,map(z->(x,z...),combination(y))...)


combination((1))
combination((2,3))
combination((2,3,4))
combination((1,2,3,4))


for i in 1:15
    print(count_ones(i)," ")
end

function one_positions_array(x::Int64, bits=64)
    out = Vector{Int}([])
    sizehint!(out,count_ones(x))
    for position in 1:bits-leading_zeros(x)
        if x&1 == 1
            push!(out,position)
        end
        x>>>=1
    end
    out
end


function one_positions_mvector(x::Int64, bits=64)
    out = zeros(MVector{count_ones(x),Int64})
    i = 1
    for position in 1:bits-leading_zeros(x)
        if x&1 == 1
            out[i]=position
            i+=1
        end
        x>>>=1
    end
    out
end

function one_positions_array2(x::Int64, bits=64)
    out = zeros(Int64,count_ones(x))
    i = 1
    for position in 1:bits-leading_zeros(x)
        if x&1 == 1
            out[i]=position
            i+=1
        end
        x>>>=1
    end
    out
end

struct OnePositions
    x :: Int64
end
IteratorSize(::Type{OnePositions}) = HasLength()
Base.length(op::OnePositions) = count_ones(op.x)
IteratorEltype(::Type{OnePositions}) = HasEltype()
Base.eltype(op::OnePositions) = Int64
function Base.iterate(op::OnePositions)
    number_of_ones = length(op)
    number_of_ones == 0 && return nothing
    remaining_ones = number_of_ones-1
    first_one_position = trailing_zeros(op.x)+1
    (first_one_position,(remaining_ones,first_one_position))
end
function Base.iterate(op::OnePositions, state)
    remaining_ones,previous_one_position = state
    x = op.x
    remaining_ones==0 && return nothing
    remaining_ones+=-1
    shifted=x>>>(previous_one_position)
    this_one_position = trailing_zeros(shifted)+1+previous_one_position
    (this_one_position,(remaining_ones,this_one_position))
end



@benchmark one_positions_array(x) setup=(x=rand(Int))
@benchmark one_positions_mvector(x) setup=(x=rand(Int))
@benchmark one_positions_array2(x) setup=(x=rand(Int))

for i in 1:20
    println(i," => ",one_positions(i))
end
for i in 1:20
    print(i," => ")
    for p in OnePositions(i)
        print(p," ")
    end
    println()
end

@benchmark sum(one_positions_array2(x)) setup=(x=rand(Int))
@benchmark sum(OnePositions(x)) setup=(x=rand(Int))
