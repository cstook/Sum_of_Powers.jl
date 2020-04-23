mutable struct Tracker
    best_a :: Vector{Int}
    best_error :: BigInt
end
function (t::Tracker)(a::Vector{Int}, e::BigInt)
    if abs(e)<abs(t.best_error)
        t.best_a=a
        t.best_error=e
    end
    nothing
end
