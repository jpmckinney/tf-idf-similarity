# Ruby Vector Space Model (VSM) with tf*idf weights

For performance, use [Lucene](http://lucene.apache.org/core/), which implements other information retrieval functions, like [BM 25](http://en.wikipedia.org/wiki/Okapi_BM25).

## Usage

    require 'tf-idf-similarity'
    corpus = TfIdfSimilarity::Collection.new
    corpus << TfIdfSimilarity::Document.new("Lorem ipsum dolor sit amet...")
    corpus << TfIdfSimilarity::Document.new("Pellentesque sed ipsum dui...")
    corpus << TfIdfSimilarity::Document.new("Nam scelerisque dui sed leo...")
    p corpus.similarity_matrix

## Extras

You can access more term frequency, document frequency, and normalization formulas with:

    require 'tf-idf-similarity/extras/collection'
    require 'tf-idf-similarity/extras/document'

The default tf*idf formula follows [Lucene](http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html).

## Papers

* [G. Salton and C. Buckley. "Term Weighting Approaches in Automatic Text Retrieval."" Technical Report. Cornell University, Ithaca, NY, USA. 1987.](http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf)
* [E. Chisholm and T. G. Kolda. "New term weighting formulas for the vector space method in information retrieval." Technical Report Number ORNL-TM-13756. Oak Ridge National Laboratory, Oak Ridge, TN, USA. 1999.](http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf)

## Bugs? Questions?

This gem's main repository is on GitHub: [http://github.com/opennorth/tf-idf-similarity](http://github.com/opennorth/tf-idf-similarity), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2012 Open North Inc., released under the MIT license
