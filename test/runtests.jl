using NetflixPrize
using Base.Test

realdata = joinpath(Pkg.dir("NetflixPrize"), "data", "download", "training_set")
testdata = joinpath(Pkg.dir("NetflixPrize"), "test", "testdata", "mv_1.txt")

#Copy test data over if real data doesn't exist
if !isdir(realdata)
    dir = joinpath(Pkg.dir("NetflixPrize"), "data")
    isdir(dir) || mkdir(dir)
    dir = joinpath(dir, "download")
    isdir(dir) || mkdir(dir)
    isdir(realdata) || mkdir(realdata)
    
    cp(testdata, joinpath(realdata, "mv_1.txt"))
end

NetflixPrize.training_set()

