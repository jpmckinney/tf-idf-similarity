# A document.
module TfIdfSimilarity
  class Document
    # The document's identifier.
    attr_reader :id
    # The document's text.
    attr_reader :text
    # The number of times each term appears in the document.
    attr_reader :term_counts
    # The number of tokens in the document.
    attr_reader :size

    # @param [String] text the document's text
    # @param [Hash] opts optional arguments
    # @option opts [String] :id the document's identifier
    # @option opts [Array] :tokens the document's tokenized text
    # @option opts [Hash] :term_counts the number of times each term appears
    # @option opts [Integer] :size the number of tokens in the document
    def initialize(text, opts = {})
      @text   = text
      @id     = opts[:id] || object_id
      @tokens = opts[:tokens]

      if opts[:term_counts]
        @term_counts = opts[:term_counts]
        @size = opts[:size] || term_counts.values.reduce(0, :+)
        # Nothing to do.
      else
        @term_counts = Hash.new(0)
        @size = 0
        set_term_counts_and_size
      end
    end

    # Returns the set of terms in the document.
    #
    # @return [Array<String>] the unique terms in the document
    def terms
      term_counts.keys
    end

    # Returns the number of occurrences of the term in the document.
    #
    # @param [String] term a term
    # @return [Integer] the number of times the term appears in the document
    def term_count(term)
      term_counts[term].to_i # need #to_i if unmarshalled
    end

  private

    # Tokenizes the text and counts terms and total tokens.
    def set_term_counts_and_size
      tokenize(text).each do |word|
        token = Token.new(word)
        if token.valid?
          term = token.lowercase_filter.classic_filter.to_s
          @term_counts[term] += 1
          @size += 1
        end
      end
    end

    # Tokenizes a text, respecting the word boundary rules from Unicode’s Default
    # Word Boundary Specification.
    #
    # If a tokenized text was provided at the document's initialization, those
    # tokens will be returned without additional processing.
    #
    # @param [String] text a text
    # @return [Enumerator] a token enumerator
    #
    # @note We should evaluate the tokenizers by {http://www.sciencemag.org/content/suppl/2010/12/16/science.1199644.DC1/Michel.SOM.revision.2.pdf Google}
    #   or {http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.UAX29URLEmailTokenizerFactory Solr}.
    #
    # @see http://unicode.org/reports/tr29/#Default_Word_Boundaries
    # @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.StandardTokenizerFactory
    def tokenize(text)
      @tokens || UnicodeUtils.each_word(text)
    end
  end
end
