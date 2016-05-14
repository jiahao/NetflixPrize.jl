#Netflix Prize data set

using JLD
using ProgressMeter

function parsefile(filename)
    data, header = readcsv(filename, header=true)
    movieid = parse(Int, header[1][1:end-1])
    userratings = sub(data, :, 1:2) #Throw away dates
    movieid, userratings
end

function parseall(dir, outputfile="../data/training_set.jld")
    info("Parsing training set")

    movies=Dict{Int,Array}()
    maxuser = 0
    maxmovieid = 0

    @showprogress for file in readdir(dir)
        file == "max.txt" && continue
        movieid, userratings = parsefile(joinpath(dir, file))
        movies[movieid] = userratings
        maxuser = max(maxuser, maximum(sub(userratings,:,1)))
        maxmovieid = max(maxmovieid, movieid)
    end

    info("Generating $maxuser x $maxmovieid sparse matrix")

    M = spzeros(UInt8,maxuser,maxmovieid)
    @showprogress for (movieid, userratings) in movies
        for i in 1:size(userratings,1)
            M[userratings[i,1], movieid] = userratings[i,2]
        end
    end

    info("Saving training set to $outputfile")
    JLD.save(outputfile, "data", M)
end

datadir = "../data/download/training_set"
if isdir(datadir)
    parseall(datadir)
else
    error("Place Netflix Prize training set in $datadir/mv_*.txt")
end
