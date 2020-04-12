using Sum_of_Powers: Solution, err
using Test

@testset "Sum_of_Powers.jl" begin
    s = Solution(15,4,[14,9,8,6,3])
    @test string(s) == "15^4=>{14,9,8,6,3}"
    err(s) = 175
end
