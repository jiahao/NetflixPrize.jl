# NetflixPrize.jl

Julia package for handling the Netflix Prize data set of 2006


This package does NOT provide the actual data itself. However, you may download it elsewhere, e.g. from 
[Academic Torrents](http://academictorrents.com/details/9b13183dc4d60676b773c9e2cd6de5e5542cee9a).
Please note that the data set itself comes with a separate license agreement.

How to use
----------

1. Place the downloaded training set tarball `nf_prize_dataset.tar.gz` in the
   `data/` directory and untar it with

    ```
    tar xzf nf_prize_dataset.tar.gz
    cd download
    tar xf training_set.tar
```

2. Loading the package will parse all the text files and create a JLD binary
   file, `data/training_set.jld`, containing a sparse matrix containing
   ratings, with rows indexed by movie ID and columns indexed by user ID.
   (Note: the raw data also contains dates, which are not saved.)
   Parsing the entire training set takes about 10-20 minutes.



Citation
--------

The Netflix Prize data set can be cited by

James Bennett, Charles Elkan, Bing Liu, Padhraic Smyth, and Domonkos Tikk,
"KDD Cup and Workshop 2007",
ACM SiGKDD Explorations Newletter, Vol 9, Iss 2, Dec 2007, pp. 51-52,
[doi:10.1145/1345448.1345459](http://dx.doi.org/10.1145/1345448.1345459)
