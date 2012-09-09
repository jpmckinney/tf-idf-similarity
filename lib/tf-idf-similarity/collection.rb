require 'matrix'

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

  # @note Use GSL or Linalg, or a package that implements sparse matrices, if
  #   Ruby's Matrix performance is too slow.
  #
  # @see http://en.wikipedia.org/wiki/Vector_space_model
  # @see http://en.wikipedia.org/wiki/Document-term_matrix
  # @see http://en.wikipedia.org/wiki/Cosine_similarity
  def similarity_matrix
    idf = []

    term_document_matrix = Matrix.build(terms.size, documents.size) do |i,j|
      idf[i] ||= inverse_document_frequency terms[i]
      documents[j].term_frequency(terms[i]) * idf[i]
    end

    # Columns are normalized to unit vectors, so we can calculate the cosine
    # similarity of all document vectors.
    matrix = normalize term_document_matrix
    matrix.transpose * matrix
  end

  # @param [String] term a term
  # @return [Float] the term's inverse document frequency
  #
  # @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html
  def inverse_document_frequency(term)
    1 + Math.log2 documents.size / (document_counts(term).to_f + 1)
  end
  alias_method :idf, :inverse_document_frequency

  # @param [Document] matrix a term-document matrix
  # @return [Matrix] a matrix in which all document vectors are unit vectors
  #
  # @note Lucene normalizes document length differently.
  def normalize(matrix)
    Matrix.columns tfidf.column_vectors.map(&:normalize)
  end
end
