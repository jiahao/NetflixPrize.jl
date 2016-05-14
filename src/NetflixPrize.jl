#Netflix Prize data set

using Glob
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

    maxusers, allmovies, allnrows, allusers, allratings =
    @time pmap(glob(joinpath(dir, "mv_*.txt"))) do file
        movieid, userratings = parsefile(file)
        users =  map(Int, sub(userratings,:,1))
        ratings = map(Int, sub(userratings,:,2))
        nrows = size(userratings, 1)
        maximum(users), movieid, nrows, users, ratings
    end

    maxuser=maximum(maxusers)
    maxmovieid=maximum(allmovies)

    info("Generating $maxuser x $maxmovieid sparse matrix")

    nnzs = sum(allnrows)
    Is = Array(Int, nnzs)
    Js = Array(Int, nnzs)
    Vs = Array(UInt8, nnzs)

    globalidx = 0
    @showprogress for chunkid in eachindex(maxusers)
        nentries = allnrows[chunkid]
        for j=1:nentries
            Is[globalidx+j] = allmovies[chunkid]
        end
        Js[globalidx+1:globalidx+nentries] = allusers[chunkid]
        Vs[globalidx+1:globalidx+nentries] = allratings[chunkid]
    end

    M = sparse(Is, Js, Vs)

    info("Saving training set to $outputfile")
    JLD.save(outputfile, "data", M)
end

addprocs(CPU_CORES-nprocs()+1)
datadir = "../data/download/training_set"
if isdir(datadir)
    parseall(datadir)
else
    error("Place Netflix Prize training set in $datadir/mv_*.txt")
end
