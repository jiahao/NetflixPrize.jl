#Netflix Prize data set
module NetflixPrize

using Glob
using JLD
using ProgressMeter

function parsefile(filename)
    data, header = readcsv(filename, header=true)
    movieid = parse(Int, header[1][1:end-1])
    userratings = sub(data, :, 1:2) #Throw away dates
    movieid, userratings
end

function parseall(datadir, outputfile=joinpath(Pkg.dir("NetflixPrize"), "data", "training_set.jld"))
    files = cd(()->glob("mv_*.txt"), datadir)

    info("Parsing training set from $(length(files)) files")

    @time parsed_data = pmap(files) do file
        movieid, userratings = parsefile(joinpath(datadir, file))
        users =  map(Int, sub(userratings,:,1))
        ratings = map(Int, sub(userratings,:,2))
        nrows = size(userratings, 1)
        maximum(users), movieid, nrows, users, ratings
    end

    maxusers = [item[1] for item in parsed_data]
    allmovies = [item[2] for item in parsed_data]
    allnrows = [item[3] for item in parsed_data]
    allusers = [item[4] for item in parsed_data]
    allratings = [item[5] for item in parsed_data]

    info("Saving intermediate data set to $outputfile")
    JLD.save(outputfile,
        "maxusers", maxusers,
        "allmovies", allmovies,
        "allnrows", allnrows,
        "allusers", allusers,
        "allratings", allratings,
          compress=true
    )

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
        globalidx += nentries
    end

    @time M = sparse(Is, Js, Vs)

    info("Saving training set to $outputfile")
    JLD.save(outputfile, "data", M, compress=true)
end

function training_set()
    const datadir = joinpath(Pkg.dir("NetflixPrize"), "data/download/training_set")
    const datafile = joinpath(Pkg.dir("NetflixPrize"), "data/training_set.jld")
    const tarball = joinpath(Pkg.dir("NetflixPrize"), "data/nf_prize_dataset.tar.gz")
    if !isdir(datadir)
        #If tarball found in user's download directory, move it into the package subtree
        const dltarball = joinpath(ENV["HOME"], "Downloads", "nf_prize_dataset.tar.gz")
        if isfile(dltarball)
            info("Copying training set tarball to $tarball")
            isdir(dirname(tarball)) || mkdir(dirname(tarball))
            cp(dltarball, tarball)
        end

        if isfile(tarball)
            info("Unpacking training set from $tarball")
            run(Cmd(`tar xzf $tarball`, dir=dirname(tarball)))
            run(Cmd(`tar xf training_set.tar`, dir=joinpath(dirname(tarball), "download")))
        else
            error("Place Netflix Prize training set in $tarball")
        end
    end

    if !isfile(datafile)
        info("Parsing Netflix prize data from $datadir into $datafile")
        parseall(datadir)
    end

    data = load(datafile, "data")
end

end
