mutable struct Tracker
    best_select_a :: BitArray{1}
    best_error :: BigInt
end
function (t::Tracker)(a::BitArray{1}, e::BigInt)
    if abs(e)<abs(t.best_error)
        t.best_select_a=a
        t.best_error=e
    end
    nothing
end
(t::Tracker)() = (t.best_select_a, t.best_error)
is_error_zero(t::Tracker) = t.best_error == 0
