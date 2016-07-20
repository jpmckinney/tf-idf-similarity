# Ruby Vector Space Model (VSM) with tf*idf weights

[![Gem Version](https://badge.fury.io/rb/tf-idf-similarity.svg)](https://badge.fury.io/rb/tf-idf-similarity)
[![Build Status](https://secure.travis-ci.org/jpmckinney/tf-idf-similarity.png)](https://travis-ci.org/jpmckinney/tf-idf-similarity)
[![Dependency Status](https://gemnasium.com/jpmckinney/tf-idf-similarity.png)](https://gemnasium.com/jpmckinney/tf-idf-similarity)
[![Coverage Status](https://coveralls.io/repos/jpmckinney/tf-idf-similarity/badge.png)](https://coveralls.io/r/jpmckinney/tf-idf-similarity)
[![Code Climate](https://codeclimate.com/github/jpmckinney/tf-idf-similarity.png)](https://codeclimate.com/github/jpmckinney/tf-idf-similarity)

Calculates the similarity between texts using a [bag-of-words](https://en.wikipedia.org/wiki/Bag_of_words_model) [Vector Space Model](https://en.wikipedia.org/wiki/Vector_space_model) with [Term Frequency-Inverse Document Frequency (tf*idf)](https://en.wikipedia.org/wiki/Tf–idf) weights. If your use case demands performance, use [Lucene](http://lucene.apache.org/core/) (see below).

## Usage

```ruby
require 'matrix'
require 'tf-idf-similarity'
```

Create a set of documents:

```ruby
document1 = TfIdfSimilarity::Document.new("Lorem ipsum dolor sit amet...")
document2 = TfIdfSimilarity::Document.new("Pellentesque sed ipsum dui...")
document3 = TfIdfSimilarity::Document.new("Nam scelerisque dui sed leo...")
corpus = [document1, document2, document3]
```

Create a document-term matrix using [Term Frequency-Inverse Document Frequency function](https://en.wikipedia.org/wiki/Tf–idf):

```ruby
model = TfIdfSimilarity::TfIdfModel.new(corpus)
```

Or, create a document-term matrix using the [Okapi BM25 ranking function](https://en.wikipedia.org/wiki/Okapi_BM25):

```ruby
model = TfIdfSimilarity::BM25Model.new(corpus)
```

Create a similarity matrix:

```ruby
matrix = model.similarity_matrix
```

Find the similarity of two documents in the matrix:

```ruby
matrix[model.document_index(document1), model.document_index(document2)]
```

Print the tf*idf values for terms in a document:

```ruby
tfidf_by_term = {}
document1.terms.each do |term|
  tfidf_by_term[term] = model.tfidf(document1, term)
end
puts tfidf_by_term.sort_by{|_,tfidf| -tfidf}
```

Tokenize a document yourself, for example by excluding stop words:

```ruby
require 'unicode_utils'
text = "Lorem ipsum dolor sit amet..."
tokens = UnicodeUtils.each_word(text).to_a - ['and', 'the', 'to']
document1 = TfIdfSimilarity::Document.new(text, :tokens => tokens)
```

Provide, by yourself, the number of times each term appears and the number of tokens in the document:

```ruby
require 'unicode_utils'
text = "Lorem ipsum dolor sit amet..."
tokens = UnicodeUtils.each_word(text).to_a - ['and', 'the', 'to']
term_counts = Hash.new(0)
size = 0
tokens.each do |token|
  # Unless the token is numeric.
  unless token[/\A\d+\z/]
    # Remove all punctuation from tokens.
    term_counts[token.gsub(/\p{Punct}/, '')] += 1
    size += 1
  end
end
document1 = TfIdfSimilarity::Document.new(text, :term_counts => term_counts, :size => size)
```

[Read the documentation at RubyDoc.info.](http://rubydoc.info/gems/tf-idf-similarity)

## Troubleshooting

```
NoMethodError: undefined method `[]' for Matrix:Module
```

The `matrix` gem conflicts with Ruby's internal `Matrix` module. Don't use the `matrix` gem.

## Speed

Instead of using the Ruby Standard Library's [Matrix](http://www.ruby-doc.org/stdlib-2.0/libdoc/matrix/rdoc/Matrix.html) class, you can use one of the [GNU Scientific Library (GSL)](http://www.gnu.org/software/gsl/), [NArray](http://narray.rubyforge.org/) or [NMatrix](https://github.com/SciRuby/nmatrix) (0.0.9 or greater) gems for faster matrix operations. For example:

    require 'narray'
    model = TfIdfSimilarity::TfIdfModel.new(corpus, :library => :narray)

NArray seems to have the best performance of the three libraries.

The NMatrix gem gives access to [Automatically Tuned Linear Algebra Software (ATLAS)](http://math-atlas.sourceforge.net/), which you may know of through [Linear Algebra PACKage (LAPACK)](http://www.netlib.org/lapack/) or [Basic Linear Algebra Subprograms (BLAS)](http://www.netlib.org/blas/). Follow [these instructions](https://github.com/SciRuby/nmatrix#installation) to install the NMatrix gem.

## Extras

You can access more term frequency, document frequency, and normalization formulas with:

    require 'tf-idf-similarity/extras/document'
    require 'tf-idf-similarity/extras/tf_idf_model'

The default tf*idf formula follows the [Lucene Conceptual Scoring Formula](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html).

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

Lucene implements many more [similarity functions](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/Similarity.html), such as:

* a [divergence from randomness (DFR) framework](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/DFRSimilarity.html)
* a [framework for the family of information-based models](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/IBSimilarity.html)
* a [language model with Bayesian smoothing using Dirichlet priors](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/LMDirichletSimilarity.html)
* a [language model with Jelinek-Mercer smoothing](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/LMJelinekMercerSimilarity.html)

Lucene can even [combine similarity measures](http://lucene.apache.org/core/4_0_0/core/org/apache/lucene/search/similarities/MultiSimilarity.html).

Copyright (c) 2012 James McKinney, released under the MIT license
