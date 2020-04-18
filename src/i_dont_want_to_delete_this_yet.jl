





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



struct Strategy{T}
    groups :: Vector{T}
end

mutable struct Solution{T<:Integer}
    s :: T
    n :: Int
    a :: Array{T,1}
end
solution(s,n) = Solution{Int}(s,n,[])
function canonical!(solution::Solution)
    sort!(solution.a)
end
function isvalid(solution::Solution)
    s = solution.s
    n = solution.n
    a = solution.a
    s<3 && return false
    n<16 && return false
    n>40 && return false
    length(a)<2 && return false
    length(a)>(s-1) && return false
    for x in a
        x<1 && return false
        x>(s-1) && return false
    end
    true
end

function Base.string(sol::Solution)
    out = string(sol.s,"^",sol.n,"=>{",sol.a[1])
    for value in sol.a[2:end]
        out = out*string(",",value)
    end
    out = out*"}"
    out
end

function err(sol::Solution, acc=BigInt(0))
    acc = acc + sol.s^sol.n
    for a in sol.a
        acc = acc - a^sol.n
    end
    acc
end

function random_search(s, n, iterations=1e5,
                             best_e=s^(BigInt(n)),
                             powers=powers_tuple_old(s,n))
    s_to_n = s^(BigInt(n))
    best_a = Vector{Int}()
    all_a = Set(1:s-1)
    gotone = false
    for i in 1:iterations
        x = copy(all_a)
        a = Vector{Int}()
        e = s_to_n
        while true
            length(x)==0 && break
            new_a = rand(x)
            pop!(x,new_a)
            new_e = e - powers[s-new_a]
            abs(new_e)>abs(e) && break
            push!(a,new_a)
            e = new_e
        end
        if abs(e)<abs(best_e)
            gotone = true
            best_e = e
            best_a = a
        end
        if best_e == 0
            break # can't get better
        end
    end
    if gotone
        return Solution(s,n,sort(best_a,rev=true)),best_e
    else
        return nothing
    end
end

function improve!(solution::Solution, strategy::Strategy;
                  powers=powers_tuple(solution.s,solution.n),
                  initial_error=err(solution),
                  s_to_n=solution.s^(BigInt(solution.n))
                  )
    current_error = BigInt(initial_error)
    new_error = BigInt(initial_error)
    current_solution = solution
    while true
        for group in strategy.groups
            new_error = best_group!(current_solution, group,
                                    powers=powers,
                                    initial_error=current_error,
                                    s_to_n = s_to_n)
        end
        new_error>=current_error && break
        current_error = new_error
    end
    solution = current_solution
    current_error
end

function best_group!(solution::Solution, group;
                     powers=powers_tuple(solution.s,solution.n),
                     initial_error=err(solution),
                     s_to_n=solution.s^(BigInt(solution.n))
                    )
    lhs = BigInt(s_to_n)
    a_not_in_group = setdiff(solution.a,group)
    for i in a_not_in_group
        lhs -= powers[i]
    end
    best_e = BigInt(initial_error)
    best_c = Array{Int,1}[]
    for c in combinations(group)
        e = BigInt(lhs)
        for i in c
            e=e-powers[i]
            e<0 && abs(e)>abs(best_e) && break
        end
        if abs(e)<=abs(best_e)
            best_e = e
            best_c = c
        end
        best_e==0 && break
    end
    best_a = sort!(union(best_c,a_not_in_group))
    solution.a = best_a
    best_e
end


powers_tuple(s,n) = ntuple(x->x^BigInt(n),s-1)
powers_tuple_old(s,n) = ntuple(x->(s-x)^BigInt(n),s-1)
function best(s,n,powers=powers_tuple_old(s,n))
    s_to_n = s^(BigInt(n))
    best_e = s_to_n
    all = collect(s-1:-1:1)
    e = s_to_n
    for i in all
        e = e - powers[s-i]
    end
    if e>=0
        return Solution(s,n,all),e
    end
    best_c = Array{Int,1}[]
    for c = combinations(s-1:-1:1)
        e = s_to_n
        for i in c
            e = e - powers[s-i]
            e<0 && abs(e)>abs(best_e) && break # teminate if hopeless
        end
        if abs(e)<abs(best_e)
            best_e = e
            best_c = c
        end
        if best_e == 0
            break # can't get better
        end
    end
    return Solution(s,n,best_c),best_e
end

function max_all_a(n)
    s=2
    while true
        powers=powers_tuple_old(s,n)
        all = collect(s-1:-1:1)
        e = s^(BigInt(n))
        for i in all
            e = e - powers[s-i]
        end
        if e<0
            return s-1
        end
        s+=1
    end
end

function print_best(io::IO,s,n,powers=powers_tuple_old(s,n))
    sol,e = best(s,n,powers)
    println(io,string(sol),",e=",string(e))
end

function print_best_to_file(s_start,s_stop,n,file="data/n$(n)best.txt")
    open(file,"a") do io
        for s in s_start:s_stop
            print_best(io,s,n)
            flush(io)
        end
    end
end







function ns()
    n = 2:17
    s = [4,5,7,8,10,11,12,14,15,17,18,20,21,23,24,26]
    n,s
end


end # module
