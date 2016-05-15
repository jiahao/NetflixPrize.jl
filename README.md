# NetflixPrize.jl

Julia package for handling the Netflix Prize data set of 2006


This package does NOT provide the actual data itself. However, you may download it elsewhere, e.g. from 
[Academic Torrents](http://academictorrents.com/details/9b13183dc4d60676b773c9e2cd6de5e5542cee9a).
Please note that the data set itself comes with a separate license agreement.

How to use
----------

1. Place the downloaded training set tarball `nf_prize_dataset.tar.gz` in
   `~/Downloads` or in the `data/` subdirectory under the package name.

2. Load the package:

   ```jl
   using NetflixPrize
   ```

2. (Optional) Fire up some Julia workers on the current node, e.g.
   
   ```jl
   addprocs(4)
   ```

   These extra workers will be used in the next step to speed up data processing.


3. To return the data set as a sparse matrix, run

   ```jl
   NetflixPrize.load()
   ```

   Where needed, `load()` will copy the tarball into the package subtree,
   unpack the tarball, parse all the text files belonging to the training set,
   and save the resulting sparse matrix in a local JLD (Julia data) file.
   
   The output is a sparse matrix containing ratings, with rows indexed by movie
   ID and columns indexed by user ID.
   (Note: the raw data also contains dates, which are not saved.)
   Parsing the entire training set can take some time.

Citation
--------

The Netflix Prize data set can be cited by

James Bennett, Charles Elkan, Bing Liu, Padhraic Smyth, and Domonkos Tikk,
"KDD Cup and Workshop 2007",
ACM SiGKDD Explorations Newletter, Vol 9, Iss 2, Dec 2007, pp. 51-52,
[doi:10.1145/1345448.1345459](http://dx.doi.org/10.1145/1345448.1345459)
