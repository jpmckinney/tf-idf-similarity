module TfIdfSimilarity
  class Model
    include MatrixMethods

    extend Forwardable
    def_delegators :@model, :documents, :terms, :document_count

    # @param [Array<Document>] documents documents
    # @param [Hash] opts optional arguments
    # @option opts [Symbol] :library :gsl, :narray, :nmatrix or :matrix (default)
    def initialize(documents, opts = {})
      @model = TermCountModel.new(documents, opts)
      @library = (opts[:library] || :matrix).to_sym

      array = Array.new(terms.size) do |i|
        idf = inverse_document_frequency(terms[i])
        Array.new(documents.size) do |j|
          (term_frequency(documents[j], terms[i]) * idf).to_f
        end
      end

      @matrix = initialize_matrix(array)
    end

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
      if documents.empty?
        []
      else
        multiply_self(normalize)
      end
    end

    # Return the index of the document in the corpus.
    #
    # @param [Document] document a document
    # @return [Integer,nil] the index of the document
    def document_index(document)
      @model.documents.index(document)
    end

    # Return the index of the document with matching text.
    #
    # @param [String] text a text
    # @return [Integer,nil] the index of the document
    def text_index(text)
      @model.documents.index do |document|
        document.text == text
      end
    end
  end
end
