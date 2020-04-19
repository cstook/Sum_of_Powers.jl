using Sum_of_Powers: Solution, err, OnePositions
using Test

@testset "Solution.jl" begin
    s = Solution(15,16,(14,9,8,6,3))
    @test string(s) == "15^16=>{3,6,8,9,14}"
    @test err(s) == BigInt(4388317701585002815)
    @test err(Solution(24,16,Tuple(1:23))) == BigInt(400030525071869538932)
end


@testset "OnePositions.jl" begin
    test_one_positions(x) = sum(map(x_->exp2(x_-1),OnePositions(x))) == x
    @test test_one_positions(0)
    @test test_one_positions(1)
    @test test_one_positions(2)
    for x in rand(1:10000,100)
        @test test_one_positions(x)
    end
end
