# @note The vss gem does not take the logarithm of the inverse document frequency.
# @see https://github.com/mkdynamic/vss/blob/master/lib/vss/engine.rb#L79

# @note The treat gem does not add one to the inverse document frequency.
# @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L16

# @note The treat gem normalizes to the number of tokens in the document.
# @see https://github.com/bbcrd/Similarity/blob/master/lib/similarity/document.rb#L42

# @see http://nlp.stanford.edu/IR-book/html/htmledition/document-and-query-weighting-schemes-1.html
# @see http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf
# @see http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf
module TfIdfSimilarity
  class TfIdfModel
    # @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L17
    #
    # SMART n, Salton x, Chisholm NONE
    def no_collection_frequency(term)
      1.0
    end

    # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L50
    #
    # SMART t, Salton f, Chisholm IDFB
    def plain_inverse_document_frequency(term, numerator = 0, denominator = 0)
      log((documents.size + numerator) / (@model.document_count(term).to_f + denominator))
    end
    alias_method :plain_idf, :plain_inverse_document_frequency

    # SMART p, Salton p, Chisholm IDFP
    def probabilistic_inverse_document_frequency(term)
      count = @model.document_count(term).to_f
      log((documents.size - count) / count)
    end
    alias_method :probabilistic_idf, :probabilistic_inverse_document_frequency

    # Chisholm IGFF
    def global_frequency_inverse_document_frequency(term)
      @model.term_count(term) / @model.document_count(term).to_f
    end
    alias_method :gfidf, :global_frequency_inverse_document_frequency

    # Chisholm IGFL
    def log_global_frequency_inverse_document_frequency(term)
      log(global_frequency_inverse_document_frequency(term) + 1)
    end
    alias_method :log_gfidf, :log_global_frequency_inverse_document_frequency

    # Chisholm IGFI
    def incremented_global_frequency_inverse_document_frequency(term)
      global_frequency_inverse_document_frequency(term) + 1
    end
    alias_method :incremented_gfidf, :incremented_global_frequency_inverse_document_frequency

    # Chisholm IGFS
    def square_root_global_frequency_inverse_document_frequency(term)
      sqrt(global_frequency_inverse_document_frequency(term) - 0.9)
    end
    alias_method :square_root_gfidf, :square_root_global_frequency_inverse_document_frequency

    # Chisholm ENPY
    def entropy(term)
      denominator = @model.term_count(term).to_f
      logN = log(documents.size)
      1 + documents.reduce(0) do |sum,document|
        quotient = document.term_count(term) / denominator
        sum += quotient * log(quotient) / logN
      end
    end

    # @see https://github.com/mkdynamic/vss/blob/master/lib/vss/engine.rb
    # @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb
    # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb
    # @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb
    # @see https://github.com/josephwilk/rsemantic/blob/master/lib/semantic/transform/tf_idf_transform.rb
    #
    # SMART n, Salton x, Chisholm NONE
    def no_normalization(matrix)
      matrix
    end

    # @see http://nlp.stanford.edu/IR-book/html/htmledition/pivoted-normalized-document-length-1.html
    #
    # SMART u, Chisholm PUQN
    def pivoted_unique_normalization(matrix)
      raise NotImplementedError
    end

    # Cosine normalization is implemented as MatrixMethods#normalize.
    #
    # SMART c, Salton c, Chisholm COSN



    # The plain term frequency is implemented as Document#term_count.
    #
    # @see https://github.com/mkdynamic/vss/blob/master/lib/vss/engine.rb#L75
    # @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L11
    #
    # SMART n, Salton t, Chisholm FREQ

    # SMART b, Salton b, Chisholm BNRY
    def binary_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        1
      else
        0
      end
    end
    alias_method :binary_tf, :binary_term_frequency

    # @see https://en.wikipedia.org/wiki/Tf*idf
    # @see http://nlp.stanford.edu/IR-book/html/htmledition/maximum-tf-normalization-1.html
    def normalized_term_frequency(document, term, a = 0)
      a + (1 - a) * document.term_count(term) / document.maximum_term_count
    end
    alias_method :normalized_tf, :normalized_term_frequency

    # SMART a, Salton n, Chisholm ATF1
    def augmented_normalized_term_frequency(document, term)
      0.5 + 0.5 * normalized_term_frequency(document, term)
    end
    alias_method :augmented_normalized_tf, :augmented_normalized_term_frequency

    # Chisholm ATFA
    def augmented_average_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        0.9 + 0.1 * count / document.average_term_count
      else
        0
      end
    end
    alias_method :augmented_average_tf, :augmented_average_term_frequency

    # Chisholm ATFC
    def changed_coefficient_augmented_normalized_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        0.2 + 0.8 * count / document.maximum_term_count
      else
        0
      end
    end
    alias_method :changed_coefficient_augmented_normalized_tf, :changed_coefficient_augmented_normalized_term_frequency

    # @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L12
    #
    # SMART l, Chisholm LOGA
    def log_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        1 + log(count)
      else
        0
      end
    end
    alias_method :log_tf, :log_term_frequency

    # SMART L, Chisholm LOGN
    def normalized_log_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        (1 + log(count)) / (1 + log(document.average_term_count))
      else
        0
      end
    end
    alias_method :normalized_log_tf, :normalized_log_term_frequency

    # Chisholm LOGG
    def augmented_log_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        0.2 + 0.8 * log(count + 1)
      else
        0
      end
    end
    alias_method :augmented_log_tf, :augmented_log_term_frequency

    # Chisholm SQRT
    def square_root_term_frequency(document, term)
      count = document.term_count(term)
      if count > 0
        sqrt(count - 0.5) + 1
      else
        0
      end
    end
    alias_method :square_root_tf, :square_root_term_frequency
  end
end
