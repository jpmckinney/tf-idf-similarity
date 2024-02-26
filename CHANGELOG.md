# Changelog

## v0.2.0

### Added

- Add `tokenizer` option to `Document` class

  The value is an object with a `tokenize` method that accepts a string and returns an array of `Token` instances. 

  For example, to use [natto](https://rubygems.org/gems/natto) instead of [unicode_utils](https://rubygems.org/gems/unicode_utils) for Japanese, install MeCab (`brew install mecab`), and then:

  ```ruby
  require 'natto'

  class Tokenizer
    def initialize
      @nm = Natto::MeCab.new
    end

    def tokenize(text)
      @nm.enum_parse(text).map do |node|
        Token.new(node)
      end
    end
  end

  document = TfIdfSimilarity::Document.new("こんにちは世界", tokenizer: tokenizer)
  ```

- Add `to_s` method to `Token` class, to use less memory than chaining `lowercase_filter` with `classic_filter`
