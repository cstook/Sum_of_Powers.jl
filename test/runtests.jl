using Sum_of_Powers: Solution, err
using Test

@testset "Sum_of_Powers.jl" begin
    s = Solution(15,16,(14,9,8,6,3))
    @test string(s) == "15^16=>{3,6,8,9,14}"
    err(s) = 175
end
