module Sum_of_Powers

export Solution, err
export search, Best, SubSet, SlidingWindow, MabeyBest

import Base.string

include("Solution.jl")
include("OnePositions.jl")
include("search.jl")
include("write_file.jl")
include("track_best.jl")

end  #module
