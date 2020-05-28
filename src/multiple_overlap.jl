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

struct IsOneData{T1,T2,T3,T4}
    tn_view :: T1
    overlap :: Int
    use_table_below :: Int
    table :: T2
    index :: T3
    table_index :: T4
    table_msb_bitmask :: Int
end
function use_table_below(bit_position::Int, cp::CommonParameters)
    overlap = cp.on[bit_position]
    # need to optimize this
    if overlap<8
        return -1
    else
        return overlap-5
    end
end
function is_one_data(bit_position::Int,
                     cp::CommonParameters,
                     utb::Int=use_table_below(bit_position,cp))
    overlap = cp.on[bit_position]
    n = cp.n
    tn = cp.tn
    k_l = bit_position-overlap
    k_h = bit_position
    if utb>0
        table_l = bit_position-overlap
        table_h = bit_position-utb
        table = make_table(k_l,k_h,n,tn)
        index = sortperm(table)
        table_index = table[index]
        table_msb_bitmask = 1 << table_h-table_l
    else
        table = nothing
        index = nothing
        table_index = nothing
        table_msb_bitmask = 0
    end
    tn_view = view(cp.tn,k_l:k_h)

    IsOneData(tn_view, overlap, utb, table, index, table_index, table_msb_bitmask)
end
# determine if one_at_k should be included in result, updates lhs
function isone(lhs::BigInt,
               iod::IsOneData,
               current_position::Int = iod.overlap)
   debugprint_true() = println(' '^(3*(iod.overlap-current_position)),current_position, true, new_lhs," ",tn[current_position+1])
   debugprint_false() = println(' '^(3*(iod.overlap-current_position)),current_position, false, lhs," ",tn[current_position+1])
    tn = iod.tn_view
    utb = iod.use_table_below
    table = iod.table
    index = iod.index
    table_index = iod.table_index
    table_msb_bitmask = iod.table_msb_bitmask
    if current_position<utb  # use the lookup table
        f = searchsortedfirst(table_index, lhs)
            lhs_a = lhs-table_index[f]
            if f>1
                lhs_b = lhs-table_index[f-1]
                if abs(lhs_a)<abs(lhs_b)
                    i = index[f]
                    ismsbset = (table_msb_bitmask & i)>0
                    return ismsbset, lhs_a
                else
                    i = index[f-1]
                    ismsbset = (table_msb_bitmask & i)>0
                    return ismsbset, lhs_b
                end
            end
        i = index[f]
        ismsbset = (table_msb_bitmask & i)>0
        return ismsbset, lhs_a
    end
    new_lhs = lhs - tn[current_position+1]
     if new_lhs == 0
         debugprint_true()
         return true, new_lhs
     end
    if current_position<1
        if new_lhs>0
            debugprint_true()
            return true, new_lhs
        else
            debugprint_false()
            return false, lhs
        end
    else
        junk_isone, lhs_zero = isone(lhs, iod, current_position-1)
        junk_isone, lhs_one = isone(new_lhs, iod, current_position-1)
        println("cp=",current_position," lhs_zero=",lhs_zero,"  lhs_one=",lhs_one)
        if  lhs_one>=0 & abs(lhs_one)<abs(lhs_zero)
            debugprint_true()
            return true, lhs_one
        else
            debugprint_false()
            return false, lhs_zero
        end
    end
end

function multiple_overlap(s, cp::CommonParameters)
    tn = cp.tn
    k_max = s-1
    one_at_k = BigInt(1)<<(k_max-1) # start with a one in k_max position
    lhs = tn[s]
    rhs_b = BigInt(0)
    best = Tracker(rhs_b,lhs)
    println();println("------------------------")
    for k in k_max:-1:1
        println("k=",k)
        one_lhs = lhs - tn[k]
        one_rhs_b = rhs_b | one_at_k
        best(rhs_b, lhs)
        best(one_rhs_b, one_lhs)
        iod = is_one_data(k,cp)
        is_iod_msb_one, junk_lhs = isone(lhs,iod)
        if is_iod_msb_one
            rhs_b = one_rhs_b
            lhs = one_lhs
        end
        one_at_k >>= 1
    end
    best()
end
