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
