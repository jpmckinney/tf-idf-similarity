# Changelog

## v0.3.0 (2024-02-26)

### Added

- Add support for [numo](https://rubygems.org/gems/numo) matrix library. @yagince @srapilly

### Changed

- Drop support for Ruby versions less than 2.4.

### Fixed

- Fix the `term_frequency` method in the `BM25Model` class, caused by a typographical error (`documents.size` instead of `document.size`).

## v0.2.0 (2019-12-19)

### Added

- Add `tokenizer` option to `Document` class. @satoryu

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

- Add `to_s` method to `Token` class, to use less memory than chaining `lowercase_filter` with `classic_filter`. @satoryu

## v0.1.6 (2017-03-07)

### Changed

- Add support for recent RubyGems and Ruby versions (`require 'delegate'`). @diasks2
- Drop support for Ruby 1.9.3.

## v0.1.5 (2016-01-17)

### Changed

- Update the `classic_filter` method of the `Token` class to remove possessives when the apostrophe is a backtick (\`) or a single quotation mark (’). @diasks2
- Drop support for Ruby 1.9.2.

## v0.1.4 (2014-10-10)

### Added

- Add the `document_index` and `text_index` methods to the `Model` class and its subclasses.

### Changed

- Extract logic from the `BM25Model` and `TfIdfModel` classes to a new `Model` class.
- Drop support for Ruby 1.8.7.

## v0.1.3 (2014-04-12)

### Changed

- Load only the required methods from the `unicode_utils` gem, to use less memory.

## v0.1.2 (2014-03-30)

### Fixed

- Install the `unicode_utils` gem only on Ruby versions greater than 1.8.

## v0.1.1 (2014-03-28)

### Changed

- Remove `:function` option from `TfIdfModel` class. Use `BM25Model` class, instead.

## v0.1.0 (2013-06-02)

Major refactor of v0.0.x.
