require 'spec_helper'

require 'tf-idf-similarity/extras/document'
require 'tf-idf-similarity/extras/tf_idf_model'

describe TfIdfSimilarity::TfIdfModel do
  # @see https://github.com/reddavis/TF-IDF/blob/master/spec/tf_idf_spec.rb
  context 'comparing to tf_idf gem' do
    let :one do
      TfIdfSimilarity::Document.new('a a a a a a a a b b')
    end

    let :two do
      TfIdfSimilarity::Document.new('a a')
    end

    let :model do
      TfIdfSimilarity::TfIdfModel.new([one, two])
    end

    # Normalizes to the number of tokens in the document.
    # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L76
    def tf
      one.term_count('b') / one.size.to_f
    end

    # Performs plain inverse document frequency with base 10.
    # @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L50
    def idf
      model.plain_idf('b') / Math.log(10)
    end

    it 'should return the term frequency' do
      tf.should == 0.2
      model.tf(one, 'b').should be_within(0.001).of(1.414)
    end

    it 'should return the inverse document frequency' do
      idf.should be_within(0.001).of(0.301) # 0.30102999
      model.idf('b').should == 1
    end

    it 'should return the tf*idf' do
      (tf * idf).should be_within(0.001).of(0.060) # 0.0602
      model.tfidf(one, 'b').should == be_within(0.001).of(1.414)
    end
  end
end
