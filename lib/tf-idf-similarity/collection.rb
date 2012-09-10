begin
  require 'gsl'
rescue LoadError
  require 'matrix'
end

class TfIdfSimilarity::Collection
  # The documents in the collection.
  attr_reader :documents
  # The number of times each term appears in all documents.
  attr_reader :term_counts
  # The number of documents each term appears in.
  attr_reader :document_counts

  def initialize
    @documents       = []
    @term_counts     = Hash.new 0
    @document_counts = Hash.new 0
  end

  def <<(document)
    document.term_counts.each do |term,count|
      @term_counts[term]     += count
      @document_counts[term] += 1
    end
    @documents << document
  end

  # @return [Array<String>] the set of the collection's terms with no duplicates
  def terms
    term_counts.keys
  end

  # @see http://en.wikipedia.org/wiki/Vector_space_model
  # @see http://en.wikipedia.org/wiki/Document-term_matrix
  # @see http://en.wikipedia.org/wiki/Cosine_similarity
  def similarity_matrix
    if matrix?
      idf = []
      term_document_matrix = Matrix.build(terms.size, documents.size) do |i,j|
        idf[i] ||= inverse_document_frequency terms[i]
        documents[j].term_frequency(terms[i]) * idf[i]
      end
    else
      term_document_matrix = if gsl?
        GSL::Matrix.alloc terms.size, documents.size
      elsif narray?
        NMatrix.float documents.size, terms.size
      elsif nmatrix?
        # The nmatrix gem's sparse matrices are unfortunately buggy.
        # @see https://github.com/SciRuby/nmatrix/issues/35
        NMatrix.new([terms.size, documents.size], :float64)
      end

      terms.each_with_index do |term,i|
        idf = inverse_document_frequency term
        documents.each_with_index do |document,j|
          tfidf = document.term_frequency(term) * idf
          if gsl? || nmatrix?
            term_document_matrix[i, j] = tfidf
          # NArray puts the dimensions in a different order.
          # @see http://narray.rubyforge.org/SPEC.en
          elsif narray?
            term_document_matrix[j, i] = tfidf
          end
        end
      end
    end

    # Columns are normalized to unit vectors, so we can calculate the cosine
    # similarity of all document vectors.
    matrix = normalize term_document_matrix

    if nmatrix?
      matrix.transpose.dot matrix
    else
      matrix.transpose * matrix
    end
  end

  # @param [String] term a term
  # @return [Float] the term's inverse document frequency
  #
  # @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html
  def inverse_document_frequency(term)
    1 + Math.log(documents.size / (document_counts[term].to_f + 1))
  end
  alias_method :idf, :inverse_document_frequency

  # @param [Document] matrix a term-document matrix
  # @return [Matrix] a matrix in which all document vectors are unit vectors
  #
  # @note Lucene normalizes document length differently.
  def normalize(matrix)
    if gsl?
      matrix.each_col(&:normalize!)
    elsif narray?
      # @todo NArray doesn't have a method to normalize a vector.
      # 0.upto(matrix.shape[0] - 1).each do |j|
      #   matrix[j, true] # Normalize this column somehow.
      # end
      matrix
    elsif nmatrix?
      # @todo NMatrix doesn't have a method to normalize a vector.
      matrix
    else
      Matrix.columns matrix.column_vectors.map(&:normalize)
    end
  end

private

  def gsl?
    @gsl     ||= Object.const_defined?(:GSL)
  end

  def narray?
    @narray  ||= Object.const_defined?(:NArray) && !gsl?
  end

  def nmatrix?
    @nmatrix ||= Object.const_defined?(:NMatrix) && !narray?
  end

  def matrix?
    @matrix  ||= Object.const_defined?(:Matrix)
  end
end
