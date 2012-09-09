class TfIdfSimilarity::Collection
  # @note SMART n, Salton x, Chisholm NONE
  def no_collection_frequency(term)
    1.0
  end

  # @note SMART t, Salton f, Chisholm IDFB
  def plain_inverse_document_frequency(term)
    count = document_counts[term].to_f
    Math.log documents.size / count
  end
  alias_method :plain_idf, :plain_inverse_document_frequency

  # @note SMART p, Salton p, Chisholm IDFP
  def probabilistic_inverse_document_frequency(term)
    count = document_counts[term].to_f
    Math.log (documents.size - count) / count
  end
  alias_method :probabilistic_idf, :probabilistic_inverse_document_frequency

  # @note Chisholm IGFF
  def global_frequency_inverse_document_frequency(term)
    term_counts[term] / document_counts[term].to_f
  end
  alias_method :gfidf, :global_frequency_inverse_document_frequency

  # @note Chisholm IGFL
  def log_global_frequency_inverse_document_frequency(term)
    Math.log global_frequency_inverse_document_frequency(term) + 1
  end
  alias_method :log_gfidf, :log_global_frequency_inverse_document_frequency

  # @note Chisholm IGFI
  def incremented_global_frequency_inverse_document_frequency(term)
    global_frequency_inverse_document_frequency(term) + 1
  end
  alias_method :incremented_gfidf, :incremented_global_frequency_inverse_document_frequency

  # @note Chisholm IGFS
  def square_root_global_frequency_inverse_document_frequency(term)
    Math.sqrt global_frequency_inverse_document_frequency(term) - 0.9
  end
  alias_method :square_root_gfidf, :square_root_global_frequency_inverse_document_frequency

  # @note Chisholm ENPY
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
  #
  # @note SMART n, Salton x, Chisholm NONE
  def no_normalization(matrix)
    matrix
  end

  # @param [Document] matrix a term-document matrix
  # @return [Matrix] a matrix in which all document vectors are unit vectors
  #
  # @note SMART c, Salton c, Chisholm COSN
  def cosine_normalization(matrix)
    Matrix.columns(tfidf.column_vectors.map do |column|
      column.normalize
    end)
  end

  # @param [Document] matrix a term-document matrix
  # @return [Matrix] a matrix
  #
  # @note SMART u, Chisholm PUQN
  def pivoted_unique_normalization(matrix)
    # @todo
    # http://nlp.stanford.edu/IR-book/html/htmledition/pivoted-normalized-document-length-1.html
  end
end
