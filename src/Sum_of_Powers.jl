module Sum_of_Powers
using OffsetArrays
using Statistics
using StatsBase
using Plots
using StatsPlots
using KernelDensity

export Solution, err
export search, Best, SubSet, SlidingWindow, MabeyBest, BinaryFixOverlap
#export BFORandom
export BinaryCorrectOverlap, a_to_n, cumulative_a_to_n
export write_file

import Base.string

include("util.jl")
include("Solution.jl")
include("OnePositions.jl")
include("multiple_overlap.jl")


include("look_up_table.jl")
# include("random_binary.jl")
include("ratio.jl")
include("track_best.jl")
include("zeros_only.jl")
include("search.jl")
include("write_file.jl")


end  #module
