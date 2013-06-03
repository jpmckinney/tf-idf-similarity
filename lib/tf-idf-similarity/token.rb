# coding: utf-8

# A token.
#
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
    if RUBY_VERSION < '1.9'
      !self[%r{
        \A
          (
           \d           | # number
           [[:cntrl:]]  | # control character
           [[:punct:]]  | # punctuation
           [[:space:]]    # whitespace
          )+
        \z
      }x]
    else
      !self[%r{
        \A
          (
           \d           | # number
           \p{Cntrl}    | # control character
           \p{Punct}    | # punctuation
           \p{Space}      # whitespace
          )+
        \z
      }x] # The Ruby 1.8 parser will complain about this regular expression.
    end
  end

  # Returns a lowercase string.
  #
  # @return [Token] a lowercase string
  #
  # @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.LowerCaseFilterFactory
  def lowercase_filter
    self.class.new(defined?(UnicodeUtils) ? UnicodeUtils.downcase(self, :fr) : downcase)
  end

  # Returns a string with no English possessive or periods in acronyms.
  #
  # @return [Token] a string with no English possessive or periods in acronyms
  #
  # @see http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters#solr.ClassicFilterFactory
  def classic_filter
    self.class.new(self.gsub('.', '').chomp("'s"))
  end
end
