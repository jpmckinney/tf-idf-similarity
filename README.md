# Ruby Vector Space Model (VSM) with tf*idf weights

[![Build Status](https://secure.travis-ci.org/opennorth/tf-idf-similarity.png)](http://travis-ci.org/opennorth/tf-idf-similarity)
[![Dependency Status](https://gemnasium.com/opennorth/tf-idf-similarity.png)](https://gemnasium.com/opennorth/tf-idf-similarity)
[![Coverage Status](https://coveralls.io/repos/opennorth/tf-idf-similarity/badge.png?branch=master)](https://coveralls.io/r/opennorth/tf-idf-similarity)
[![Code Climate](https://codeclimate.com/github/opennorth/tf-idf-similarity.png)](https://codeclimate.com/github/opennorth/tf-idf-similarity)

Calculates the similarity between texts using a [bag-of-words](http://en.wikipedia.org/wiki/Bag_of_words_model) [Vector Space Model](http://en.wikipedia.org/wiki/Vector_space_model) with [Term Frequency-Inverse Document Frequency (tf*idf)](http://en.wikipedia.org/wiki/
) weights. If your use case demands performance, use [Lucene](http://lucene.apache.org/core/) (see below).

## Usage

    require 'matrix'
    require 'tf-idf-similarity'

Create a set of documents:

    corpus = []
    corpus << TfIdfSimilarity::Document.new("Lorem ipsum dolor sit amet...")
    corpus << TfIdfSimilarity::Document.new("Pellentesque sed ipsum dui...")
    corpus << TfIdfSimilarity::Document.new("Nam scelerisque dui sed leo...")

Create a document-term matrix using [Term Frequency-Inverse Document Frequency function](http://en.wikipedia.org/wiki/) (default):

    model = TfIdfSimilarity::TfIdfModel.new(corpus, :function => :tf_idf)

Create a document-term matrix using the [Okapi BM25 ranking function](http://en.wikipedia.org/wiki/Okapi_BM25):

    model = TfIdfSimilarity::TfIdfModel.new(corpus, :function => :bm25)

[Read the documentation at RubyDoc.info.](http://rubydoc.info/gems/tf-idf-similarity)

## Speed

Instead of using the Ruby Standard Library's [Matrix](http://www.ruby-doc.org/stdlib-2.0/libdoc/matrix/rdoc/Matrix.html) class, you can use one of the [GNU Scientific Library (GSL)](http://www.gnu.org/software/gsl/), [NArray](http://narray.rubyforge.org/) or [NMatrix](https://github.com/SciRuby/nmatrix) (0.0.9 or greater) gems for faster matrix operations. For example:

    require 'gsl'
    model = TfIdfSimilarity::TfIdfModel.new(corpus, :library => :gsl)

The NMatrix gem gives access to [Automatically Tuned Linear Algebra Software (ATLAS)](http://math-atlas.sourceforge.net/), which you may know of through [Linear Algebra PACKage (LAPACK)](http://www.netlib.org/lapack/) or [Basic Linear Algebra Subprograms (BLAS)](http://www.netlib.org/blas/). Follow [these instructions](https://github.com/SciRuby/nmatrix#synopsis) to install the NMatrix gem. You may need [additional instructions for Mac OS X Lion](https://github.com/SciRuby/nmatrix/wiki/Installation).

## Extras

You can access more term frequency, document frequency, and normalization formulas with:

    require 'tf-idf-similarity/extras/document'
    require 'tf-idf-similarity/extras/tf_idf_model'

The default tf*idf formula follows the [Lucene Conceptual Scoring Formula](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html).

## Why?

At the time of writing, no other Ruby gem implemented the tf*idf formula used by Lucene, Sphinx and Ferret.

* [rsemantic](https://github.com/josephwilk/rsemantic) now uses the same [term frequency](https://github.com/josephwilk/rsemantic/blob/master/lib/semantic/transform/tf_idf_transform.rb#L14) and [document frequency](https://github.com/josephwilk/rsemantic/blob/master/lib/semantic/transform/tf_idf_transform.rb#L13) formulas as Lucene.
* [treat](https://github.com/louismullie/treat) offers many term frequency formulas, [one of which](https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L13) is the same as Lucene.
* [similarity](https://github.com/bbcrd/Similarity) uses [cosine normalization](https://github.com/bbcrd/Similarity/blob/master/lib/similarity/term_document_matrix.rb#L23), which corresponds roughly to Lucene.

### Term frequencies

* The [vss](https://github.com/mkdynamic/vss) gem does not normalize the frequency of a term in a document; this occurs frequently in the academic literature, but only to demonstrate why normalization is important.
* The [tf_idf](https://github.com/reddavis/TF-IDF) and similarity gems normalize the frequency of a term in a document to the number of terms in that document, which never occurs in the literature.
* The [tf-idf](https://github.com/mchung/tf-idf) gem normalizes the frequency of a term in a document to the number of *unique* terms in that document, which never occurs in the literature.

### Document frequencies

* The vss gem does not normalize the inverse document frequency.
* The treat, tf_idf, tf-idf and similarity gems use variants of the typical inverse document frequency formula.

### Normalization

* The treat, tf_idf, tf-idf, rsemantic and vss gems have no normalization component.

## Additional adapters

Adapters for the following projects were also considered:

* [Ruby-LAPACK](http://ruby.gfd-dennou.org/products/ruby-lapack/) is a very thin wrapper around LAPACK, which has an opaque Fortran-style naming scheme.
* [Linalg](https://github.com/quix/linalg) and [RNum](http://rnum.rubyforge.org/) give access to LAPACK from Ruby but are old and unavailable as gems.

## Reference

* [G. Salton and C. Buckley. "Term Weighting Approaches in Automatic Text Retrieval."" Technical Report. Cornell University, Ithaca, NY, USA. 1987.](http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf)
* [E. Chisholm and T. G. Kolda. "New term weighting formulas for the vector space method in information retrieval." Technical Report Number ORNL-TM-13756. Oak Ridge National Laboratory, Oak Ridge, TN, USA. 1999.](http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf)

## Further Reading

Lucene implements many more [similarity functions](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/Similarity.html), such as:

* a [divergence from randomness (DFR) framework](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/DFRSimilarity.html)
* a [framework for the family of information-based models](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/IBSimilarity.html)
* a [language model with Bayesian smoothing using Dirichlet priors](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/LMDirichletSimilarity.html)
* a [language model with Jelinek-Mercer smoothing](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/LMJelinekMercerSimilarity.html)

Lucene can even [combine similarity measures](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/MultiSimilarity.html).

## Bugs? Questions?

This gem's main repository is on GitHub: [http://github.com/opennorth/tf-idf-similarity](http://github.com/opennorth/tf-idf-similarity), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2012 Open North Inc., released under the MIT license
