# Ruby Vector Space Model (VSM) with tf*idf weights

[![Dependency Status](https://gemnasium.com/opennorth/tf-idf-similarity.png)](https://gemnasium.com/opennorth/tf-idf-similarity)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/opennorth/tf-idf-similarity)

Calculates the similarity between texts using a [bag-of-words](http://en.wikipedia.org/wiki/Bag_of_words_model) [Vector Space Model](http://en.wikipedia.org/wiki/Vector_space_model) with [Term Frequency-Inverse Document Frequency](http://en.wikipedia.org/wiki/Tf*idf) weights. If your use case demands performance, use [Lucene](http://lucene.apache.org/core/) or similar (see below).

## Usage

    require 'tf-idf-similarity'

    corpus = TfIdfSimilarity::Collection.new
    corpus << TfIdfSimilarity::Document.new("Lorem ipsum dolor sit amet...")
    corpus << TfIdfSimilarity::Document.new("Pellentesque sed ipsum dui...")
    corpus << TfIdfSimilarity::Document.new("Nam scelerisque dui sed leo...")

    p corpus.similarity_matrix

## Optimizations

This gem will use the first available library below, for faster matrix multiplication.

### [GNU Scientific Library (GSL)](http://www.gnu.org/software/gsl/)

The latest [gsl gem](http://rb-gsl.rubyforge.org/) (`1.14.7`) is [not compatible](http://bretthard.in/2012/03/getting-related_posts-lsi-and-gsl-to-work-in-jekyll/) with the `gsl` package (`1.15`) in Homebrew:

```sh
cd /usr/local
git checkout -b gsl-1.14 83ed49411f076e30ced04c2cbebb054b2645a431
brew install gsl
git checkout master
git branch -d gsl-1.14
```

Be careful not to upgrade `gsl` to `1.15` with `brew upgrade outdated`. You can now run:

    gem install gsl --no-ri --no-rdoc

### [NArray](http://narray.rubyforge.org/)

    gem install narray

### [Automatically Tuned Linear Algebra Software (ATLAS)](http://math-atlas.sourceforge.net/)

You may know this software through [Linear Algebra PACKage (LAPACK)](http://www.netlib.org/lapack/) or [Basic Linear Algebra Subprograms (BLAS)](http://www.netlib.org/blas/). You can use it through the next release (after `0.0.2`) of the [nmatrix gem](https://github.com/SciRuby/nmatrix). Follow [these instructions](https://github.com/SciRuby/nmatrix#synopsis) to install it. You may need [additional instructions for Mac OS X Lion](https://github.com/SciRuby/nmatrix/wiki/NMatrix-Installation).

### Other Options

[Ruby-LAPACK](http://ruby.gfd-dennou.org/products/ruby-lapack/) is a very thin wrapper around LAPACK, which has an opaque Fortran-style naming scheme. [Linalg](https://github.com/quix/linalg) and [RNum](http://rnum.rubyforge.org/) are old and not available as gems.

## Extras

You can access more term frequency, document frequency, and normalization formulas with:

    require 'tf-idf-similarity/extras/collection'
    require 'tf-idf-similarity/extras/document'

The default tf*idf formula follows the [Lucene Conceptual Scoring Formula](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html).

## Why?

No other Ruby gem implements the tf*idf formula used by Lucene, Sphinx and Ferret.

### Term frequencies

The [vss](https://github.com/mkdynamic/vss) gem does not normalize the frequency of a term in a document, which occurs frequently in the academic literature, but only to demonstrate why normalization is important. The [treat](https://github.com/louismullie/treat), [tf_idf](https://github.com/reddavis/TF-IDF), [similarity](https://github.com/bbcrd/Similarity) and [rsemantic](https://github.com/josephwilk/rsemantic) gems normalize the frequency of a term in a document to the number of terms in that document, which never occurs in the literature. The [tf-idf](https://github.com/mchung/tf-idf) gem normalizes the frequency of a term in a document to the number of *unique* terms in that document, which never occurs in the literature.

### Document frequencies

The vss gem does not normalize the inverse document frequency. The tf_idf, tf-idf, similarity and rsemantic gems use variants of the typical inverse document frequency formula.

### Normalization

The treat, tf_idf, tf-idf, rsemantic and vss gems have no normalization component.

## Reference

* [G. Salton and C. Buckley. "Term Weighting Approaches in Automatic Text Retrieval."" Technical Report. Cornell University, Ithaca, NY, USA. 1987.](http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf)
* [E. Chisholm and T. G. Kolda. "New term weighting formulas for the vector space method in information retrieval." Technical Report Number ORNL-TM-13756. Oak Ridge National Laboratory, Oak Ridge, TN, USA. 1999.](http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf)

## Further Reading

Lucene implements many more [similarity functions](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/Similarity.html), such as:

* a [divergence from randomness (DFR) framework](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/DFRSimilarity.html)
* a [framework for the family of information-based models](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/IBSimilarity.html)
* a [language model with Bayesian smoothing using Dirichlet priors](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/LMDirichletSimilarity.html)
* a [language model with Jelinek-Mercer smoothing](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/LMJelinekMercerSimilarity.html)

Lucene can even [combine similarity meatures](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/MultiSimilarity.html).

## Bugs? Questions?

This gem's main repository is on GitHub: [http://github.com/opennorth/tf-idf-similarity](http://github.com/opennorth/tf-idf-similarity), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2012 Open North Inc., released under the MIT license
