@testset "Solution_file.jl" begin
    using Sum_of_Powers: parse_solution_error, MabeyBest, search,
            Solution, SolutionError, BinaryFixOverlap
    file = "test_solutions.txt"
    for stratagy in [MabeyBest(),BinaryFixOverlap()]
        open(file,"r") do io
            for line in readlines(io)
                file_solution, file_e = parse_solution_error(line,false)
                s = file_solution.s
                n = file_solution.n
                search_a, search_e = search(stratagy, s, n)
                search_solution = Solution(s,n,search_a,false)
                if abs(file_e)!=abs(search_e) # may find a different solution
                    @test SolutionError(search_solution) == SolutionError(file_solution)
                end
            end
        end
    end
end
