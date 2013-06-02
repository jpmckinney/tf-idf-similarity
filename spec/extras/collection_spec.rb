require 'spec_helper'

require 'tf-idf-similarity/extras/collection'
require 'tf-idf-similarity/extras/document'

describe TfIdfSimilarity::Collection do
  let :collection do
    TfIdfSimilarity::Collection.new
  end

  # Normalizes to the number of unique tokens (terms) in the document.
  # @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb#L172
  #
  # @see https://github.com/mchung/tf-idf/blob/master/spec/tf-idf_spec.rb
  context 'comparing to tf-idf gem' do
    before :each do
      @one = TfIdfSimilarity::Collection.new

      50.times do |n|
        text = []
        text << 'the' if n < 23
        text << 'a' if n < 17
        text << 'said' if n < 5
        text << 'phone' if n < 2
        text << 'girl' if n < 1
        text << 'moon' if n < 1
        @one << TfIdfSimilarity::Document.new(text * ' ')
      end

      @two = TfIdfSimilarity::Collection.new

      50.times do |n|
        text = []
        text << 'the' if n < 23
        text << 'a' if n < 17
        text << 'said' if n < 5
        text << 'phone' if n < 2
        text << 'girl' if n < 1
        @two << TfIdfSimilarity::Document.new(text * ' ')
      end
    end

    it 'should return the number of documents' do
      @one.documents.size.should == 50
    end

    it 'should return the number of terms' do
      @one.terms.size.should == 6
    end

    # Adds one to the numerator when calculating inverse document frequency.
    # Sets a default inverse document frequency for non-occurring terms.
    # @note The tf-idf gem has a #doc_keywords method for non-corpus documents.
    # @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb#L153
    it 'should return the inverse document frequency' do
      # should query IDF for nonexistent terms
      default = @one.plain_idf('xxx', 1, 1)
      @one.plain_idf('nonexistent', 1, 1).should == default
      @one.plain_idf('THE', 1, 1).should == default

      # should query IDF for existent terms
      @one.plain_idf('a', 1, 1).should > @one.plain_idf('the', 1, 1)
      @one.plain_idf('girl', 1, 1).should == @one.plain_idf('moon', 1, 1)

      # should add input documents to an existing corpus
      @one.plain_idf('water', 1, 1).should == default
      @one.plain_idf('moon', 1, 1).should be_within(0.001).of(3.238) # 3.23867845216438
      @one.plain_idf('said', 1, 1).should be_within(0.001).of(2.140) # 2.14006616349627

      @one << TfIdfSimilarity::Document.new('water moon')

      @one.plain_idf('water', 1, 1).should be_within(0.001).of(3.258) # 3.25809653802148
      @one.plain_idf('moon', 1, 1).should be_within(0.001).of(2.852) # 2.85263142991332
      @one.plain_idf('said', 1, 1).should be_within(0.001).of(2.159) # 2.15948424935337

      # should add input documents to an empty corpus
      @three = TfIdfSimilarity::Collection.new

      default = @three.plain_idf('xxx', 1, 1)
      @three.plain_idf('moon', 1, 1).should == default
      @three.plain_idf('water', 1, 1).should == default
      @three.plain_idf('said', 1, 1).should == default

      @three << TfIdfSimilarity::Document.new('moon')
      @three << TfIdfSimilarity::Document.new('moon said hello')

      default = @three.plain_idf('xxx', 1, 1)
      @three.plain_idf('water', 1, 1).should == default
      @three.plain_idf('said', 1, 1).should be_within(0.001).of(0.405) # 0.405465108108164
      @three.plain_idf('moon', 1, 1).should == 0 # 0

      # should observe stopwords list
      default = @two.plain_idf('xxx', 1, 1)
      @two.plain_idf('water', 1, 1).should == default
      @two.plain_idf('moon', 1, 1).should == default # returns 0 for stopwords
      @two.plain_idf('said', 1, 1).should == be_within(0.001).of(2.140) # 2.14006616349627

      @two << TfIdfSimilarity::Document.new('moon', :tokens => %w())
      @two << TfIdfSimilarity::Document.new('moon and water', :tokens => %w(and water))

      default = @two.plain_idf('xxx', 1, 1)
      @two.plain_idf('water', 1, 1).should == be_within(0.001).of(3.277) # 3.27714473299218
      @two.plain_idf('moon', 1, 1).should == default # returns 0 for stopwords
      @two.plain_idf('said', 1, 1).should == be_within(0.001).of(2.178) # 2.17853244432407
    end
  end

  # @see https://github.com/reddavis/TF-IDF/blob/master/spec/tf_idf_spec.rb
  context 'comparing to tf_idf gem' do
    let :one do
      TfIdfSimilarity::Document.new('a a a a a a a a b b')
    end

    let :two do
      TfIdfSimilarity::Document.new('a a')
    end

    before :each do
      collection << one
      collection << two
    end

    # Normalizes to the number of tokens in the document.
    # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L76
    def tf
      one.plain_tf('b') / one.size.to_f
    end

    # Performs plain inverse document frequency with base 10.
    # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L50
    def idf
      collection.plain_idf('b') / Math.log(10)
    end

    it 'should return the term frequency' do
      tf.should == 0.2
      collection.tf(one, 'b').should be_within(0.001).of(1.414)
    end

    it 'should return the inverse document frequency' do
      idf.should be_within(0.001).of(0.301) # 0.30102999
      collection.idf('b').should == 1
    end

    it 'should return the tf*idf' do
      (tf * idf).should be_within(0.001).of(0.060) # 0.0602
      collection.tfidf(one, 'b').should == be_within(0.001).of(1.414)
    end
  end
end
