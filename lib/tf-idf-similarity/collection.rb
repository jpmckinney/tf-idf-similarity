# @todo Do speed comparison between these gsl and narray, to load fastest first.
begin
  require 'gsl'
rescue LoadError
  begin
    require 'narray'
  rescue LoadError
    begin
      require 'nmatrix'
    rescue LoadError
      require 'matrix'
    end
  end
end

class TfIdfSimilarity::Collection
  class CollectionError < StandardError; end

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

  # @param [Hash] opts optional arguments
  # @option opts [Symbol] :function one of :tfidf (default) or :bm25
  #
  # @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html
  # @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/BM25Similarity.html
  # @see http://en.wikipedia.org/wiki/Vector_space_model
  # @see http://en.wikipedia.org/wiki/Document-term_matrix
  # @see http://en.wikipedia.org/wiki/Cosine_similarity
  # @see http://en.wikipedia.org/wiki/Okapi_BM25
  def similarity_matrix(opts = {})
    if documents.empty?
      raise CollectionError, "No documents in collection"
    end

    # Calculate tf*idf.
    if stdlib?
      idf = []
      matrix = Matrix.build(terms.size, documents.size) do |i,j|
        idf[i] ||= inverse_document_frequency(terms[i], opts)
        idf[i] * term_frequency(documents[j], terms[i], opts)
      end
    else
      matrix = initialize_matrix
      terms.each_with_index do |term,i|
        idf = inverse_document_frequency(term, opts)
        documents.each_with_index do |document,j|
          value = idf * term_frequency(document, term, opts)
          # NArray puts the dimensions in a different order.
          # @see http://narray.rubyforge.org/SPEC.en
          if narray?
            matrix[j, i] = value
          else
            matrix[i, j] = value
          end
        end
      end
    end

    # Columns are normalized to unit vectors, so we can calculate the cosine
    # similarity of all document vectors. BM25 doesn't normalize columns, but
    # BM25 wasn't written with this use case in mind.
    matrix = normalize matrix

    if nmatrix?
      matrix.transpose.dot matrix
    else
      matrix.transpose * matrix
    end
  end

  # @param [Document] document a document
  # @param [String] term a term
  # @param [Hash] opts optional arguments
  # @option opts [Symbol] :function one of :tfidf (default) or :bm25
  # @return [Float] the term's frequency in the document
  def term_frequency_inverse_document_frequency(document, term, opts = {})
    inverse_document_frequency(term, opts) * term_frequency(document, term, opts)
  end
  alias_method :tfidf, :term_frequency_inverse_document_frequency

  # @param [String] term a term
  # @param [Hash] opts optional arguments
  # @option opts [Symbol] :function one of :tfidf (default) or :bm25
  # @return [Float] the term's inverse document frequency
  def inverse_document_frequency(term, opts = {})
    if opts[:function] == :bm25
      Math.log (documents.size - document_counts[term] + 0.5) / (document_counts[term] + 0.5)
    else
      1 + Math.log(documents.size / (document_counts[term].to_f + 1))
    end
  end
  alias_method :idf, :inverse_document_frequency

  # @param [Document] document a document
  # @param [String] term a term
  # @param [Hash] opts optional arguments
  # @option opts [Symbol] :function one of :tfidf (default) or :bm25
  # @return [Float] the term's frequency in the document
  #
  # @note Like Lucene, we use a b value of 0.75 and a k1 value of 1.2.
  def term_frequency(document, term, opts = {})
    if opts[:function] == :bm25
      (document.term_counts[term].to_i * 2.2) / (document.term_counts[term].to_i + 0.3 + 0.9 * document.size / average_document_size)
    else
      document.term_frequency term
    end
  end
  alias_method :tf, :term_frequency

  # @return [Float] the average document size, in terms
  def average_document_size
    if documents.empty?
      raise CollectionError, "No documents in collection"
    end

    @average_document_size ||= documents.map(&:size).reduce(:+) / documents.size.to_f
  end

  # Resets the average document size.
  #
  # If you have already made a similarity matrix and are adding more documents,
  # call this method before creating a new similarity matrix.
  def reset_average_document_size!
    @average_document_size = nil
  end

  # @param [Document] matrix a term-document matrix
  # @return [GSL::Matrix,NMatrix,Matrix] a matrix in which all document vectors are unit vectors
  #
  # @note Lucene normalizes document length differently.
  def normalize(matrix)
    if gsl?
      matrix.each_col(&:normalize!)
    elsif narray?
      # @see https://github.com/masa16/narray/issues/21
      NMatrix.refer(matrix / NMath.sqrt((matrix ** 2).sum(1).reshape(documents.size, 1)))
    elsif nmatrix?
      # @see https://github.com/SciRuby/nmatrix/issues/38
      (0...matrix.shape[1]).each do |j|
        column = matrix.column(j)
        norm = Math.sqrt(column.transpose.dot(column)[0, 0])
        (0...m.shape[0]).each do |i|
          m[i, j] /= norm
        end
      end
      matrix.cast :yale, :float64
    else
      Matrix.columns matrix.column_vectors.map(&:normalize)
    end
  end

private

  # @return a matrix
  def initialize_matrix
    if gsl?
      GSL::Matrix.alloc terms.size, documents.size
    elsif narray?
      NArray.float documents.size, terms.size
    elsif nmatrix?
      NMatrix.new(:list, [terms.size, documents.size], :float64)
    end
  end

  # @return [Boolean] whether to use the GSL gem
  def gsl?
    @gsl     ||= Object.const_defined?(:GSL)
  end

  # @return [Boolean] whether to use the NArray gem
  def narray?
    @narray  ||= Object.const_defined?(:NArray) && !gsl?
  end

  # @return [Boolean] whether to use the NMatrix gem
  def nmatrix?
    @nmatrix ||= Object.const_defined?(:NMatrix) && !gsl? && !narray?
  end

  # @return [Boolean] whether to use the standard library
  def stdlib?
    @matrix  ||= Object.const_defined?(:Matrix)
  end
end
