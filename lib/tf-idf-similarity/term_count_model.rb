# A simple document-term matrix.
module TfIdfSimilarity
  class TermCountModel
    include MatrixMethods

    # The documents in the corpus.
    attr_reader :documents
    # The set of terms in the corpus.
    attr_reader :terms
    # The average number of tokens in a document.
    attr_reader :average_document_size

    # @param [Array<Document>] documents documents
    # @param [Hash] opts optional arguments
    # @option opts [Symbol] :library :gsl, :narray, :nmatrix or :matrix (default)
    def initialize(documents, opts = {})
      @documents = documents
      @terms = Set.new(documents.map(&:terms).flatten).to_a
      @library = (opts[:library] || :matrix).to_sym

      array = Array.new(terms.size) do |i|
        Array.new(documents.size) do |j|
          documents[j].term_count(terms[i])
        end
      end

      @matrix = initialize_matrix(array)

      @average_document_size = documents.empty? ? 0 : sum / column_size.to_f
    end

    # @param [String] term a term
    # @return [Integer] the number of documents the term appears in
    def document_count(term)
      index = terms.index(term)
      if index
        case @library
        when :gsl, :narray
          row(index).where.size
        when :numo
          (row(index).ne 0).where.size
        when :nmatrix
          row(index).each.count(&:nonzero?)
        else
          vector = row(index)
          unless vector.respond_to?(:count)
            vector = vector.to_a
          end
          vector.count(&:nonzero?)
        end
      else
        0
      end
    end

    # @param [String] term a term
    # @return [Integer] the number of times the term appears in the corpus
    def term_count(term)
      index = terms.index(term)
      if index
        case @library
        when :gsl, :narray, :numo
          row(index).sum
        when :nmatrix
          row(index).each.reduce(0, :+) # NMatrix's `sum` method is slower
        else
          vector = row(index)
          unless vector.respond_to?(:reduce)
            vector = vector.to_a
          end
          vector.reduce(0, :+)
        end
      else
        0
      end
    end
  end
end
