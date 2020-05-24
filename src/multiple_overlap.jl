# binary search with fix for multiple overlap

struct CommonParameters{T1,T2,T3}
    tn :: T1
    ctn :: T1
    k_max :: Int
    n :: Int
    ot :: T2
    on :: T3
end

function common_parameters(k_max, n)
    tn = a_to_n(k_max, n)
    ctn = cumulative_a_to_n(k_max, n, tn)
    ot,on = overlap_terms_number(k_max, n, tn, ctn)
    CommonParameters(tn, ctn, k_max, n, ot, on)
end

# inefficient for a large table
function make_table(k_l, k_h, n, tn=[BigInt(x)^n for x in k_l:k_h])
    table_length =  2^(k_h-k_l+1)
    t = Vector{BigInt}(undef, table_length)
    table = OffsetVector(t, 0:table_length-1)
    for i in 0:table_length-1
        table[i] = sum(tn[OnePositions(i)])
    end
    table
end

struct IsOneData{T1,T2}
    tn_view :: T1
    overlap :: Int
    use_table_below :: Int
    table :: T2
    index :: Int
end
function use_table_below(bit_position::Int, cp::CommonParameters)

end
function is_one_data(bit_position::Int,
                     cp::CommonParameters,
                     utb::Int=use_table_below(bit_position,cp))

end
# determine if one_at_k should be included in result
function isone(one_at_k::BigInt, lhs::BigInt, iod::IsOneData)

end
