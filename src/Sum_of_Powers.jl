module Sum_of_Powers

export Solution, err
export search, Best, SubSet, SlidingWindow, MabeyBest, BinaryFixOverlap, BFORandom
export BinaryCorrectOverlap, a_to_n, cumulative_a_to_n
export write_file

import Base.string

include("Solution.jl")
include("OnePositions.jl")
include("look_up_table.jl")
include("random_binary.jl")
include("track_best.jl")
include("search.jl")
include("write_file.jl")


end  #module
