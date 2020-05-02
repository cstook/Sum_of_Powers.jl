using Test

@testset "Solution.jl" begin
    using Sum_of_Powers: Solution, err
    s = Solution(15,16,(14,9,8,6,3))
    @test string(s) == "15^16=>{3,6,8,9,14}"
    @test err(s) == BigInt(4388317701585002815)
    @test err(Solution(24,16,Tuple(1:23))) == BigInt(400030525071869538932)
end

@testset "OnePositions.jl" begin
    using Sum_of_Powers: OnePositions
    test_one_positions(x::T) where {T<:Integer} = sum(map(x_->T(2)^(x_-1),OnePositions(x))) == x
    @test test_one_positions(0)
    @test test_one_positions(1)
    @test test_one_positions(2)
    @test test_one_positions(Int16(2)^15-1)
    @test test_one_positions(Int32(2)^31-1)
    @test test_one_positions(Int64(2)^63-1)
    @test test_one_positions(Int128(2)^127-1)
    for x in rand(1:Int64(2)^63-1,10)
        @test test_one_positions(x)
    end
    for x in rand(1:Int128(2)^127-1,10)
        @test test_one_positions(x)
    end
    a = [1,2,3,4,5,6,7]
    @test setdiff(a[OnePositions(10)],[2,4])==[] # getindex
    b = falses(8)
    b[OnePositions(10)] = 1
    @test b==[0,1,0,1,0,0,0,0] # setindex!
end

@testset "track_best.jl" begin
    using Sum_of_Powers: Tracker, is_error_zero
    s = 10
    n = 5
    lhs = BigInt(s)^n
    a = 0
    best = Tracker{Int}(a,lhs)
    best(31,-lhs-1)
    (best_a,best_e) = best()
    @test best_a==a
    @test ~is_error_zero(best)
    new_a = 255
    best(new_a,BigInt(0))
    (best_a,best_e) = best()
    @test best_a==new_a
    @test is_error_zero(best)
end

@testset "search.jl" begin
    using Sum_of_Powers: search, Best, SubSet, SlidingWindow, MabeyBest
    a, e = search(Best(),20,10)
    @test e == BigInt(8584238000)
    @test a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 18, 19]
    search(Best(),20,10,[1,2,3,4]) # should ignore array

    ss = SubSet([x for x in 1:8])
    s = 20
    n = 16
    a = [x for x in 1:19]
    known_e = 168716336388812100534 # for {19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1}
    a,e = search(ss,s,n,a)
    @test e==known_e
    @test setdiff(a,[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19])==[]

    ss = SubSet([14,13,4,5,6,10])
    s = 16
    n = 10
    a = [15,12,11]
    known_e = -2106698499
    a,e = search(ss,s,n,a)
    @test e==known_e
    @test setdiff(a,[15,14,13,12,11,10])==[]
    sol = Solution(s,n,a,false)
    @test err(sol) == known_e
    # best 28^16=>{27,26,24,23,20,19,18,17},e=-3923372792424650116
    s = 28
    n = 16
    a = Vector{Int}()
    sw = SlidingWindow(10)
    a,e = search(sw,s,n,a)
    @test e==-3923372792424650116 # SlidingWindow found the best!
    @test setdiff(a,[27, 26, 24, 23, 20, 19, 18, 17])==[]
end

include("verify_against_known_solutions_in_file.jl")

@testset "look_up_table.jl" begin
    using Sum_of_Powers: a_to_n, cumulative_a_to_n, problem_terms, drop_terms,
    insert_zeros, issequential, sorted_up_to, isallsorted, IncludedTerms, search
    @test a_to_n(5,2)==[1,4,9,16,25]
    @test a_to_n(0,2)==[]
    @test a_to_n(5,40)==[1,1099511627776,12157665459056928801,1208925819614629174706176,9094947017729282379150390625]
    @test cumulative_a_to_n(5,2) == [1,5,14,30,55]
    @test cumulative_a_to_n(0,2) == []
    @test cumulative_a_to_n(5,40) == [1,1099511627777,12157666558568556578,1208937977281187743262754,9096155955706563566893653379]
    @test drop_terms(5,4) == ([],[1,2,3,4,5])
    @test drop_terms(10,4) == ([8,10],[1,2,3,4,5,6,7,9])
    @test drop_terms(70,40) == ([60,64,67,70],[collect(1:59);[61,62,63,65,66,68,69]])
    @test drop_terms(5,0) == ([3, 4, 5], [1, 2])
    @test drop_terms(1,5) == (Int64[], [1])
    @test insert_zeros(0x00ff,[1]) == 0x01fe
    @test insert_zeros(0x00ff,Int[]) == 0x00ff
    @test insert_zeros(0x00ff,Int[1,3,5,7]) == 0x0faa
    @test insert_zeros(BigInt(0xffffffffffffffffffff),[1,2,3,4,70]) == 0x1fffdffffffffffffffff0
    max_k=63;n=2; @test sorted_up_to(max_k,n) == 16
    sorted_up_to_dict = Dict(2=>0x10, 3=>0x20, 4=>0x80, 5=>0x100, 6=>0x400,
      7=>0x800, 8=>0x2000, 9=>0x4000, 10=>0x8000, 11=>0x20000, 12=>0x40000, 13=>0x100000,
      14=>0x200000, 15=>0x800000, 16=>0x1000000, 17=>0x4000000, 18=>0x8000000)
    max_k = 63
    for n in 3:10
        @test sorted_up_to(max_k,n) == sorted_up_to_dict[n]
    end
    stratagy = IncludedTerms()
    included_terms_test_string =
    """
    3^2=>{1,2},e=4
    4^2=>{1,2,3},e=2
    4^5=>{1,2,3},e=748
    10^4=>{1,2,3,4,5,7,9},e=59
    24^16=>{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23},e=400030525071869538932
    """
    io = IOBuffer(included_terms_test_string)
    for line in readlines(io)
        string_solution, file_e = parse_solution_error(line,false)
        s = string_solution.s
        n = string_solution.n
        search_a, search_e = search(stratagy, s, n)
        search_solution = Solution(s,n,search_a,false)
        @test SolutionError(search_solution) == SolutionError(string_solution)
    end
end
