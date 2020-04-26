mutable struct Tracker{T<:Integer}
    best_a :: T
    best_error :: BigInt
end
function (t::Tracker)(a, e::BigInt)
    if abs(e)<abs(t.best_error)
        t.best_a=a
        t.best_error=e
    end
    nothing
end
(t::Tracker)() = (t.best_a, t.best_error)
is_error_zero(t::Tracker) = t.best_error == 0
