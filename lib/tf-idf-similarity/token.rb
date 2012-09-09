# @note We can add more filters from Solr and stem using Porter's Snowball.
#
# @see https://github.com/aurelian/ruby-stemmer
# @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.StopFilterFactory
# @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.WordDelimiterFilterFactory
# @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.SynonymFilterFactory
class TfIdfSimilarity::Token < String
  # Returns a falsy value if all its characters are numbers, punctuation,
  # whitespace or control characters.
  #
  # @note Some implementations ignore one and two-letter words.
  #
  # @return [Boolean] whether the string is a token
  def valid?
    token[%r{
      \A
        (
         \d           | # number
         \p{Cntrl}    | # control character
         \p{Punct}    | # punctuation
         [[:space:]]    # whitespace
        )+
      \z
    }x]
  end

  # @return [String] a lowercase string
  #
  # @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.LowerCaseFilterFactory
  def lowercase_filter
    UnicodeUtils.downcase self, :fr
  end

  # @return [String] a string with no English possessive or periods in acronyms
  #
  # @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.ClassicFilterFactory
  def classic_filter
    self.gsub('.', '').chomp "'s"
  end
end
