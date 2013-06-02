require 'spec_helper'

describe TfIdfSimilarity::Collection do
  let :text do
    "FOO-foo BAR bar \r\n\t 123 !@#"
  end

  let :document do
    TfIdfSimilarity::Document.new(text)
  end

  let :collection do
    TfIdfSimilarity::Collection.new
  end

  context 'without documents' do
    describe '#documents' do
      it 'should be empty' do
        collection.documents.should == []
      end
    end

    describe '#term_counts' do
      it 'should be empty' do
        collection.term_counts.should == {}
      end
    end

    describe '#document_counts' do
      it 'should be empty' do
        collection.document_counts.should == {}
      end
    end

    describe '#terms' do
      it 'should be empty' do
        collection.terms.should == []
      end
    end

    describe '#similarity_matrix' do
      it 'should raise an error' do
        expect{collection.similarity_matrix}.to raise_error(TfIdfSimilarity::Collection::CollectionError)
      end
    end

    describe '#term_frequency_inverse_document_frequency' do
      it 'should return negative infinity' do
        collection.tfidf(document, 'foo').should == -1/0.0 # -Infinity
      end
    end

    describe '#inverse_document_frequency' do
      it 'should return negative infinity' do
        collection.idf('foo').should == -1/0.0 # -Infinity
      end
    end

    describe '#term_frequency' do
      it 'should return the term frequency' do
        collection.tf(document, 'foo').should == Math.sqrt(2)
      end
    end

    describe '#average_document_size' do
      it 'should raise an error' do
        expect{collection.average_document_size}.to raise_error(TfIdfSimilarity::Collection::CollectionError)
      end
    end

    describe '#normalize', :if => lambda{MATRIX_LIBRARY == :matrix} do
      it 'should normalize the matrix' do
        collection.normalize(Matrix.build(1, 1){2}).should == Matrix.build(1, 1){1}
      end
    end
  end

  context 'with documents' do
    describe '#documents' do
    end

    describe '#term_counts' do
    end

    describe '#document_counts' do
    end

    describe '#<<' do
    end

    describe '#terms' do
    end

    describe '#similarity_matrix' do
    end

    describe '#term_frequency_inverse_document_frequency' do
    end

    describe '#inverse_document_frequency' do
    end

    describe '#term_frequency' do
    end

    describe '#average_document_size' do
    end

    describe '#reset_average_document_size!' do
    end

    describe '#normalize' do
    end

    # https://github.com/josephwilk/rsemantic/blob/master/spec/semantic/transform/tf_idf_transform_spec.rb
    # https://github.com/bbcrd/Similarity/tree/master/test
    # https://github.com/mkdynamic/vss/blob/master/test/test.rb
  end
end
