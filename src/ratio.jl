function ratio(k_max,n)
    r = Vector{Float64}()
    sizehint!(r,k_max)
    push!(r,1.0)
    previous_ktn = 1.0
    for k in BigInt(2):BigInt(k_max)
        ktn = k^n
        push!(r,ktn/previous_ktn)
        previous_ktn = ktn
    end
    r
end
