module Sum_of_Powers

export Solution, err
export search, Best, SubSet, SlidingWindow
export write_file, write_io


import Base.string

include("Solution.jl")
include("OnePositions.jl")
include("search.jl")
include("write_file.jl")

end  #module
