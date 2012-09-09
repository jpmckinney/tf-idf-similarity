# coding: utf-8
require 'unicode_utils'

class TfIdfSimilarity::Document
  # An optional document identifier.
  attr_reader :id
  # The document's text.
  attr_reader :text
  # The number of times each term appears in the document.
  attr_reader :term_counts

  # @param [String] text the document's text
  # @param [Hash] opts optional arguments
  # @option opts [String] :id a string to identify the document
  def initialize(text, opts = {})
    @text        = text
    @id          = opts[:id] || object_id
    @term_counts = Hash.new 0
    process
  end

  # @return [Array<String>] the set of the document's terms with no duplicates
  def terms
    term_counts.keys
  end
  
  # @param [String] term a term
  # @return [Float] the square root of the term count
  #
  # @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html
  def term_frequency(term)
    Math.sqrt term_counts[term]
  end
  alias_method :tf, :term_frequency

private

  # Tokenize the text and counts terms.
  def process
    tokenize(text).each do |word|
      token = TfIdfSimilarity::Token.new word
      if token.valid?
        @term_counts[token.lowercase_filter.classic_filter.to_s] += 1
      end
    end
  end

  # Tokenizes a text, respecting the word boundary rules from Unicode’s Default
  # Word Boundary Specification.
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
    UnicodeUtils.each_word text
  end
end
