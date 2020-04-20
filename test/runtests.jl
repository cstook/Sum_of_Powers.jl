using Sum_of_Powers: Solution, err, OnePositions, search, Best
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
    for x in rand(1:Int64(2)^63-1,100)
        @test test_one_positions(@show x)
    end
    for x in rand(1:Int128(2)^127-1,100)
        @test test_one_positions(@show x)
    end
end

@testset "search.jl" begin
    a_k, e = search(20,10,Best())
    @test e == BigInt(8584238000)
    @test a_k == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 18, 19]
end
