# A document-term matrix using the BM25 function.
#
# @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/BM25Similarity.html
# @see http://en.wikipedia.org/wiki/Okapi_BM25
class TfIdfSimilarity::BM25Model
  include TfIdfSimilarity::MatrixMethods

  extend Forwardable
  def_delegators :@model, :documents, :terms, :document_count

  # @param [Array<TfIdfSimilarity::Document>] documents documents
  # @param [Hash] opts optional arguments
  # @option opts [Symbol] :library :gsl, :narray, :nmatrix or :matrix (default)
  def initialize(documents, opts = {})
    @model = TfIdfSimilarity::TermCountModel.new(documents, opts)
    @library = (opts[:library] || :matrix).to_sym

    array = Array.new(terms.size) do |i|
      idf = inverse_document_frequency(terms[i])
      Array.new(documents.size) do |j|
        term_frequency(documents[j], terms[i]) * idf
      end
    end

    @matrix = initialize_matrix(array)
  end

  # Return the term's inverse document frequency.
  #
  # @param [String] term a term
  # @return [Float] the term's inverse document frequency
  def inverse_document_frequency(term)
    df = @model.document_count(term)
    log((documents.size - df + 0.5) / (df + 0.5))
  end
  alias_method :idf, :inverse_document_frequency

  # Returns the term's frequency in the document.
  #
  # @param [Document] document a document
  # @param [String] term a term
  # @return [Float] the term's frequency in the document
  #
  # @note Like Lucene, we use a b value of 0.75 and a k1 value of 1.2.
  def term_frequency(document, term)
    tf = document.term_count(term)
    (tf * 2.2) / (tf + 0.3 + 0.9 * documents.size / @model.average_document_size)
  end
  alias_method :tf, :term_frequency

  # Return the term frequency–inverse document frequency.
  #
  # @param [Document] document a document
  # @param [String] term a term
  # @return [Float] the term frequency–inverse document frequency
  def term_frequency_inverse_document_frequency(document, term)
    inverse_document_frequency(term) * term_frequency(document, term)
  end
  alias_method :tfidf, :term_frequency_inverse_document_frequency

  # Returns a similarity matrix for the documents in the corpus.
  #
  # @return [GSL::Matrix,NMatrix,Matrix] a similarity matrix
  # @note Columns are normalized to unit vectors, so we can calculate the cosine
  #   similarity of all document vectors.
  def similarity_matrix
    multiply_self(normalize)
  end
end
