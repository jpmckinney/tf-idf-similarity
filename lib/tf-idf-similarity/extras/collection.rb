require 'tf-idf-similarity/collection'

# @note The treat and similarity gems do not add one to the inverse document frequency.
# @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L16
# @see https://github.com/bbcrd/Similarity/blob/master/lib/similarity/corpus.rb#L44
#
# @note The tf-idf gem adds one to the numerator when calculating inverse document frequency.
# @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb#L153
#
# @note The vss gem does not take the logarithm of the inverse document frequency.
# @see https://github.com/mkdynamic/vss/blob/master/lib/vss/engine.rb#L79
#
# @see http://nlp.stanford.edu/IR-book/html/htmledition/document-and-query-weighting-schemes-1.html
# @see http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf
# @see http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf
class TfIdfSimilarity::Collection
  # https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L17
  #
  # SMART n, Salton x, Chisholm NONE
  def no_collection_frequency(term)
    1.0
  end

  # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L50
  #
  # SMART t, Salton f, Chisholm IDFB
  def plain_inverse_document_frequency(term)
    Math.log documents.size / document_counts[term].to_f
  end
  alias_method :plain_idf, :plain_inverse_document_frequency

  # SMART p, Salton p, Chisholm IDFP
  def probabilistic_inverse_document_frequency(term)
    count = document_counts[term].to_f
    Math.log (documents.size - count) / count
  end
  alias_method :probabilistic_idf, :probabilistic_inverse_document_frequency

  # Chisholm IGFF
  def global_frequency_inverse_document_frequency(term)
    term_counts[term] / document_counts[term].to_f
  end
  alias_method :gfidf, :global_frequency_inverse_document_frequency

  # Chisholm IGFL
  def log_global_frequency_inverse_document_frequency(term)
    Math.log global_frequency_inverse_document_frequency(term) + 1
  end
  alias_method :log_gfidf, :log_global_frequency_inverse_document_frequency

  # Chisholm IGFI
  def incremented_global_frequency_inverse_document_frequency(term)
    global_frequency_inverse_document_frequency(term) + 1
  end
  alias_method :incremented_gfidf, :incremented_global_frequency_inverse_document_frequency

  # Chisholm IGFS
  def square_root_global_frequency_inverse_document_frequency(term)
    Math.sqrt global_frequency_inverse_document_frequency(term) - 0.9
  end
  alias_method :square_root_gfidf, :square_root_global_frequency_inverse_document_frequency

  # Chisholm ENPY
  def entropy(term)
    denominator = term_counts[term].to_f
    logN = Math.log documents.size
    1 + documents.reduce(0) do |sum,document|
      quotient = document.term_counts[term] / denominator
      sum += quotient * Math.log(quotient) / logN
    end
  end



  # @param [Document] matrix a term-document matrix
  # @return [Matrix] the same matrix
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

  # @param [Document] matrix a term-document matrix
  # @return [Matrix] a matrix
  # @todo http://nlp.stanford.edu/IR-book/html/htmledition/pivoted-normalized-document-length-1.html
  #
  # SMART u, Chisholm PUQN
  def pivoted_unique_normalization(matrix)
    raise NotImplementedError
  end


  # Cosine normalization is implemented as TfIdfSimilarity::Collection#normalize.
  #
  # SMART c, Salton c, Chisholm COSN
end
