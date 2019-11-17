require 'unicode_utils/each_word'
require 'tf-idf-similarity/token'

# A tokenizer using UnicodeUtils to tokenize a text.
#
# @see https://github.com/lang/unicode_utils
module TfIdfSimilarity
  class Tokenizer
    # Tokenizes a text.
    #
    # @param [String] text
    # @return [Enumerator] an enumerator of Token objects
    def tokenize(text)
      UnicodeUtils.each_word(text).map do |word|
        Token.new(word)
      end
    end
  end
end
