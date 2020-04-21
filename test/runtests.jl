using Sum_of_Powers: Solution, err, OnePositions, search, Best, SubSet, SlidingWindow
using Test

@testset "Solution.jl" begin
    s = Solution(15,16,(14,9,8,6,3))
    @test string(s) == "15^16=>{3,6,8,9,14}"
    @test err(s) == BigInt(4388317701585002815)
    @test err(Solution(24,16,Tuple(1:23))) == BigInt(400030525071869538932)
end


@testset "OnePositions.jl" begin
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
end

@testset "search.jl" begin
    a, e = search(20,10,Best())
    @test e == BigInt(8584238000)
    @test a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 18, 19]

    ss = SubSet([x for x in 1:8])
    s = 20
    n = 16
    a = [x for x in 1:19]
    known_e = 168716336388812100534 # for {19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1}
    a,e = search(s,n,a,ss)
    @test e==known_e
    @test setdiff(a,[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19])==[]

    ss = SubSet([14,13,4,5,6,10])
    s = 16
    n = 10
    a = [15,12,11]
    known_e = -2106698499
    a,e = search(s,n,a,ss)
    @test e==known_e
    @test setdiff(a,[15,14,13,12,11,10])==[]
    sol = Solution(s,n,a,false)
    @test err(sol) == known_e

    # best 28^16=>{27,26,24,23,20,19,18,17},e=-3923372792424650116
    s = 28
    n = 16
    a = Vector{Int}()
    sw = SlidingWindow(10)
    a,e = search(s,n,a,sw)
    @test e==-3923372792424650116 # SlidingWindow found the best!
    @test setdiff(a,[27, 26, 24, 23, 20, 19, 18, 17])==[]

end
