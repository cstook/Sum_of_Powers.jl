a_to_n(k_max, n) = [BigInt(x)^n for x in 1:k_max]
function cumulative_a_to_n(k_max, n, to_n=a_to_n(k_max,n))
    x = Vector{BigInt}(undef,k_max)
    y = 0
    for k in 1:k_max
        y += to_n[k]
        x[k] = y
    end
    x
end
function overlap_terms(k_max, n, tn=a_to_n(k_max,n), ctn=cumulative_a_to_n(k_max,n,tn))
    lookback = 1
    ot = Vector{Int}()
    for k in 2:k_max
        e = tn[k]-ctn[k-lookback]
        if e<0
            push!(ot,k)
            lookback+=1
        end
    end
    ot
end
function overlap_terms_number(k_max, n, tn=a_to_n(k_max,n), ctn=cumulative_a_to_n(k_max,n,tn))
    lookback = 1
    ot = Vector{Int}()
    on = Vector{Int}()
    sizehint!(on,k_max)
    push!(on,lookback-1)
    for k in 2:k_max
        e = tn[k]-ctn[k-lookback]
        if e<0
            push!(ot,k)
            lookback+=1
        end
        push!(on,lookback-1)
    end
    ot,on
end
