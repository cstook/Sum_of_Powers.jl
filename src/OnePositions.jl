struct OnePositions{T<:Integer}
    x :: T
end
IteratorSize(::Type{OnePositions}) = HasLength()
Base.length(op::OnePositions) = count_ones(op.x)
IteratorEltype(::Type{OnePositions}) = HasEltype()
Base.eltype(op::OnePositions{T}) where {T<:Integer}= T
function Base.iterate(op::OnePositions{T}) where {T<:Integer}
    number_of_ones = length(op)
    number_of_ones == zero(T) && return nothing
    remaining_ones = number_of_ones-one(T)
    first_one_position = trailing_zeros(op.x)+one(T)
    (first_one_position,(remaining_ones,first_one_position))
end
function Base.iterate(op::OnePositions{T}, state) where {T<:Integer}
    remaining_ones,previous_one_position = state
    x = op.x
    remaining_ones==zero(T) && return nothing
    remaining_ones-=one(T)
    shifted=x>>>(previous_one_position)
    this_one_position = trailing_zeros(shifted)+previous_one_position+one(T)
    (this_one_position,(remaining_ones,this_one_position))
end

function Base.getindex(a::AbstractArray ,op::OnePositions{T})  where T
    [a[x] for x in op]
end
function Base.setindex!(a::BitArray{1}, x::Union{Bool,Integer}, op::OnePositions)
    for i in op
        a[i] = x
    end
end

# Similar performance to sum(a[pos]).  Probably do not need this.
function sum_one_positions(a::Vector{T}, pos::OnePositions) where T
    s = zero(T)
    for e in pos
        s+=e
    end
    s
end
