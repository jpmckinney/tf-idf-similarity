require 'spec_helper'

module TfIdfSimilarity
  describe TermCountModel do
    let :text do
      "FOO-foo BAR bar \r\n\t 123 !@#"
    end

    let :tokens do
      ['FOO-foo', 'BAR', 'bar', "\r\n\t", '123', '!@#']
    end

    let :document_without_text do
      Document.new('')
    end

    let :document do
      Document.new(text)
    end

    let :document_with_tokens do
      Document.new(text, :tokens => tokens)
    end

    let :document_with_term_counts do
      Document.new(text, :term_counts => {'bar' => 5, 'baz' => 10})
    end

    context 'without documents', :empty_matrix => true do
      let :model do
        TermCountModel.new([], :library => MATRIX_LIBRARY)
      end

      describe '#documents' do
        it 'should be empty' do
          model.documents.should be_empty
        end
      end

      describe '#terms' do
        it 'should be empty' do
          model.terms.should be_empty
        end
      end

      describe '#average_document_size' do
        it 'should be zero' do
          model.average_document_size.should == 0
        end
      end

      describe '#document_count' do
        it 'should be zero' do
          model.document_count('xxx').should == 0
        end
      end

      describe '#term_count' do
        it 'should be zero' do
          model.term_count('xxx').should == 0
        end
      end
    end

    context 'with documents' do
      let :documents do
        [
          document, # 4 tokens
          document_with_tokens, # 3 tokens
          document_without_text, # 0 tokens
          document_with_term_counts, # 15 tokens
        ]
      end

      let :model do
        TermCountModel.new(documents, :library => MATRIX_LIBRARY)
      end

      describe '#documents' do
        it 'should return the documents' do
          model.documents.should == documents
        end
      end

      describe '#terms' do
        it 'should return the terms' do
          model.terms.to_a.sort.should == ['bar', 'baz', 'foo', 'foo-foo']
        end
      end

      describe '#average_document_size' do
        it 'should return the average number of tokens in a document' do
          model.average_document_size.should == 5.5
        end
      end

      describe '#document_count' do
        it 'should return the number of documents the term appears in' do
          model.document_count('bar').should == 3
        end
      end

      describe '#term_count' do
        it 'should return the number of times the term appears in the corpus' do
          model.term_count('bar').should == 9
        end
      end
    end
  end
end
