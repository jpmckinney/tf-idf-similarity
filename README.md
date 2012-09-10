# Ruby Vector Space Model (VSM) with tf*idf weights

Calculates the similarity between texts using a [bag-of-words](http://en.wikipedia.org/wiki/Bag_of_words_model) [Vector Space Model](http://en.wikipedia.org/wiki/Vector_space_model) with [Term Frequency-Inverse Document Frequency](http://en.wikipedia.org/wiki/Tf*idf) weights. If your use case demands performance, use [Lucene](http://lucene.apache.org/core/) (or similar), which also implements other information retrieval functions like [BM 25](http://en.wikipedia.org/wiki/Okapi_BM25).

## Usage

    require 'tf-idf-similarity'

    corpus = TfIdfSimilarity::Collection.new
    corpus << TfIdfSimilarity::Document.new("Lorem ipsum dolor sit amet...")
    corpus << TfIdfSimilarity::Document.new("Pellentesque sed ipsum dui...")
    corpus << TfIdfSimilarity::Document.new("Nam scelerisque dui sed leo...")

    p corpus.similarity_matrix

This gem will use the [gsl gem](http://rb-gsl.rubyforge.org/) if available, for faster matrix multiplication.

## Optimizations

### [GNU Scientific Library (GSL)](http://www.gnu.org/software/gsl/)

The latest `gsl` gem (`1.14.7`) is [not compatible](http://bretthard.in/2012/03/getting-related_posts-lsi-and-gsl-to-work-in-jekyll/) with the `gsl` package (`1.15`) in Homebrew:

```sh
cd /usr/local
git checkout -b gsl-1.14 83ed49411f076e30ced04c2cbebb054b2645a431
brew install gsl
git checkout master
git branch -d gsl-1.14
gem install gsl
```

### [Automatically Tuned Linear Algebra Software (ATLAS)](http://math-atlas.sourceforge.net/)

You may know this software through [Linear Algebra PACKage (LAPACK)](http://www.netlib.org/lapack/) or [Basic Linear Algebra Subprograms (BLAS)](http://www.netlib.org/blas/).

The `nmatrix` gem (`0.0.1`) can't find the `cblas.h` and `clapack.h` header files. Either [set the C_INCLUDE_PATH](https://github.com/SciRuby/nmatrix#synopsis):

    export C_INCLUDE_PATH=/System/Library/Frameworks/Accelerate.framework/Versions/Current/Frameworks/vecLib.framework/Versions/Current/Headers/

Or [create links](https://github.com/SciRuby/nmatrix/issues/21) before installing the gem:

    sudo ln -s /System/Library/Frameworks/Accelerate.framework/Versions/Current/Frameworks/vecLib.framework/Versions/Current/Headers/cblas.h /usr/include/cblas.h
    sudo ln -s /System/Library/Frameworks/Accelerate.framework/Versions/Current/Frameworks/vecLib.framework/Versions/Current/Headers/clapack.h /usr/include/clapack.h

Version `0.0.2` [doesn't compile on Mac OS X Lion](https://github.com/SciRuby/nmatrix/issues/34).

### Other Considerations

The [narray](http://narray.rubyforge.org/) and [nmatrix](http://sciruby.com/nmatrix/) gems have no method to calculate the magnitude of a vector. [Ruby-LAPACK](http://ruby.gfd-dennou.org/products/ruby-lapack/) is a very thin wrapper around LAPACK, which has an opaque Fortran-style naming scheme. [Linalg](https://github.com/quix/linalg) and [RNum](http://rnum.rubyforge.org/) and old and not available as gems.

## Extras

You can access more term frequency, document frequency, and normalization formulas with:

    require 'tf-idf-similarity/extras/collection'
    require 'tf-idf-similarity/extras/document'

The default tf*idf formula follows the [Lucene Conceptual Scoring Formula](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html).

## Reference

* [G. Salton and C. Buckley. "Term Weighting Approaches in Automatic Text Retrieval."" Technical Report. Cornell University, Ithaca, NY, USA. 1987.](http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf)
* [E. Chisholm and T. G. Kolda. "New term weighting formulas for the vector space method in information retrieval." Technical Report Number ORNL-TM-13756. Oak Ridge National Laboratory, Oak Ridge, TN, USA. 1999.](http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf)

## Bugs? Questions?

This gem's main repository is on GitHub: [http://github.com/opennorth/tf-idf-similarity](http://github.com/opennorth/tf-idf-similarity), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2012 Open North Inc., released under the MIT license
