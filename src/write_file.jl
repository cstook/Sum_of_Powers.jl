
function write_file(srange,
                    n::Integer,
                    sw::SlidingWindow=SlidingWindow(18),
                    file_name_suffix::String="slidingwindow$(sw.width)")
    file = "data/n$(n)$(file_name_suffix).txt"
    open(file,"a") do io
        write_io(io,srange,n,sw)
    end
end

function write_file(srange,
                    n::Integer,
                    ::MabeyBest,
                    file_name_suffix::String="mabeybest")
    file = "data/n$(n)$(file_name_suffix).txt"
    open(file,"a") do io
        write_io(io,srange,n,MabeyBest())
    end
end
function write_file(srange,
                    n::Integer,
                    ::BinaryFixOverlap,
                    file_name_suffix::String="fixoverlap")
    file = "data/n$(n)$(file_name_suffix).txt"
    open(file,"a") do io
        write_io(io,srange,n,BinaryFixOverlap())
    end
end
function write_io(io::IO,srange,n::Integer,::BinaryFixOverlap)
    maxs = maximum(srange)
    tn=a_to_n(maxs,n)
    ctn=cumulative_a_to_n(maxs, n, tn)
    for s in srange
        a,e = @timev search(BinaryFixOverlap(),s,n,tn,ctn)
        sol = Solution(s,n,a,false)
        @assert e == err(sol)
        println(io,string(sol),",e=",string(e))
        flush(io)
    end
end


function write_io(io::IO,srange,n::Integer,sw::SlidingWindow=SlidingWindow(18))
    for s in srange
        a = Vector{Int}()
        a,e = search(s,n,a,sw)
        sol = Solution(s,n,a)
        @assert e == err(sol)
        println(io,string(sol),",e=",string(e))
        flush(io)
    end
end

function write_io(io::IO,srange,n::Integer,::MabeyBest)
    for s in srange
        a,e = search(MabeyBest(),s,n)
        sol = Solution(s,n,a,false)
        @assert e == err(sol)
        println(io,string(sol),",e=",string(e))
        flush(io)
    end
end
