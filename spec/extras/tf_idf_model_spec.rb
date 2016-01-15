require 'spec_helper'

require 'tf-idf-similarity/extras/document'
require 'tf-idf-similarity/extras/tf_idf_model'

module TfIdfSimilarity
  describe TfIdfModel do
    def build_document(text, opts = {})
      Document.new(text, opts)
    end

    def build_model(documents)
      TfIdfModel.new(documents, :library => MATRIX_LIBRARY)
    end

    # @see https://github.com/josephwilk/rsemantic/blob/master/spec/semantic/transform/tf_idf_transform_spec.rb
    # No relevant tests to reproduce.

    # @see https://github.com/mkdynamic/vss/blob/master/test/test.rb
    context 'comparing to vss gem' do
      let :documents do
        [ "I'm not even going to mention any TV series.",
          "The Wire is the best thing ever. Fact.",
          "Some would argue that Lost got a bit too wierd after season 2.",
          "Lost is surely not in the same league as The Wire.",
          "You cannot compare the The Wire and Lost.",
        ].map do |text|
          build_document(text)
        end
      end

      let :model do
        build_model(documents)
      end

      skip "Add #search"
    end

    # @see https://github.com/bbcrd/Similarity/blob/master/test/test_corpus.rb
    # @see https://github.com/bbcrd/Similarity/blob/master/test/test_document.rb
    # @see https://github.com/bbcrd/Similarity/blob/master/test/test_term_document_matrix.rb
    context 'comparing to similarity gem' do
      let :document do
        Document.new('cow cow cow horse horse elephant')
      end

      def build_model_from_text(*texts)
        build_model(texts.map{|text| build_document(text)})
      end

      let :model_a do
        build_model_from_text("cow horse sheep", "horse bird dog")
      end

      let :model_b do
        build_model_from_text("cow cow cow bird", "horse horse horse bird")
      end

      let :model_c do
        build_model_from_text("cow cow cow", "horse horse horse")
      end

      # Normalizes to the number of tokens in the document.
      # @see https://github.com/bbcrd/Similarity/blob/master/lib/similarity/document.rb#L42
      def tf(term)
        document.term_count(term) / document.size.to_f
      end

      # Does not add one to the inverse document frequency.
      # @see https://github.com/bbcrd/Similarity/blob/master/lib/similarity/corpus.rb#L44
      def idf(model, term)
        model.plain_idf(term, 0, 1)
      end

      it 'should return the terms' do
        [ "the quick brown fox",
          "the quick     brown   fox",
          "The Quick Brown Fox",
          'The, Quick! Brown. "Fox"',
        ].each do |text|
          build_document(text).terms.sort.should == ["brown", "fox", "quick", "the"]
        end
      end

      it 'should return the number of documents' do
        model_a.documents.size.should == 2
      end

      it 'should return the number of terms' do
        document.terms.size.should == 3
        model_a.terms.size.should == 5
      end

      it 'should return the term frequency' do
        tf('cow').should == 0.5
        tf('horse').should be_within(0.001).of(0.333)
        tf('sheep').should == 0
      end

      it 'should return the similarity matrix' do
        skip "Calculate the tf*idf matrix like the similarity gem does"
      end

      it 'should return the number of documents in which a term appears' do
        model_b.document_count('cow').should == 1
        model_b.document_count('horse').should == 1
        model_b.document_count('bird').should == 2
      end

      it 'should return the inverse document frequency' do
        idf(model_c, 'cow').should be_within(0.001).of(0.0)
        idf(model_c, 'bird').should be_within(0.001).of(0.693)
      end

      it 'should return the document vector' do
        skip "Calculate the tf*idf matrix like the similarity gem does"
      end
    end

    # @see https://github.com/mchung/tf-idf/blob/master/spec/tf-idf_spec.rb
    context 'comparing to tf-idf gem' do
      # Normalizes to the number of unique tokens (terms) in the document.
      # @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb#L172

      let :corpus_a do
        1.upto(50).map do |n|
          text = []
          text << 'the' if n <= 23
          text << 'a' if n <= 17
          text << 'said' if n <= 5
          text << 'phone' if n <= 2
          text << 'girl' if n <= 1
          text << 'moon' if n <= 1
          build_document(text * ' ')
        end
      end

      let :corpus_b do
        1.upto(50).map do |n|
          text = []
          text << 'the' if n <= 23
          text << 'a' if n <= 17
          text << 'said' if n <= 5
          text << 'phone' if n <= 2
          text << 'girl' if n <= 1
          build_document(text * ' ')
        end
      end

      let :model_a do
        build_model(corpus_a)
      end

      let :model_b do
        build_model(corpus_b)
      end

      it 'should return the number of documents' do
        model_a.documents.size.should == 50
      end

      it 'should return the number of terms' do
        model_a.terms.size.should == 6
      end

      # Adds one to the numerator when calculating inverse document frequency.
      # Sets a default inverse document frequency for non-occurring terms.
      # @note The tf-idf gem has a #doc_keywords method for non-corpus documents.
      # @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb#L153
      it 'should return the inverse document frequency' do
        # should query IDF for nonexistent terms
        default = model_a.plain_idf('xxx', 1, 1)
        model_a.plain_idf('nonexistent', 1, 1).should == default
        model_a.plain_idf('THE', 1, 1).should == default

        # should query IDF for existent terms
        model_a.plain_idf('a', 1, 1).should > model_a.plain_idf('the', 1, 1)
        model_a.plain_idf('girl', 1, 1).should == model_a.plain_idf('moon', 1, 1)

        # should add input documents to an existing corpus
        model_a.plain_idf('water', 1, 1).should == default
        model_a.plain_idf('moon', 1, 1).should be_within(0.001).of(3.238) # 3.23867845216438
        model_a.plain_idf('said', 1, 1).should be_within(0.001).of(2.140) # 2.14006616349627

        model = build_model(corpus_a + [build_document('water moon')])

        model.plain_idf('water', 1, 1).should be_within(0.001).of(3.258) # 3.25809653802148
        model.plain_idf('moon', 1, 1).should be_within(0.001).of(2.852) # 2.85263142991332
        model.plain_idf('said', 1, 1).should be_within(0.001).of(2.159) # 2.15948424935337

        # should add input documents to an empty corpus
        unless MATRIX_LIBRARY == :gsl
          model_c = build_model([])

          default = model_c.plain_idf('xxx', 1, 1)
          model_c.plain_idf('moon', 1, 1).should == default
          model_c.plain_idf('water', 1, 1).should == default
          model_c.plain_idf('said', 1, 1).should == default
        end

        model_d = build_model([
          build_document('moon'),
          build_document('moon said hello'),
        ])

        default = model_d.plain_idf('xxx', 1, 1)
        model_d.plain_idf('water', 1, 1).should == default
        model_d.plain_idf('said', 1, 1).should be_within(0.001).of(0.405) # 0.405465108108164
        model_d.plain_idf('moon', 1, 1).should == 0 # 0

        # should observe stopwords list
        default = model_b.plain_idf('xxx', 1, 1)
        model_b.plain_idf('water', 1, 1).should == default
        model_b.plain_idf('moon', 1, 1).should == default # returns 0 for stopwords
        model_b.plain_idf('said', 1, 1).should be_within(0.001).of(2.140) # 2.14006616349627

        model_e = build_model(corpus_b + [
          build_document('moon', :tokens => %w()),
          build_document('moon and water', :tokens => %w(and water)),
        ])

        default = model_e.plain_idf('xxx', 1, 1)
        model_e.plain_idf('water', 1, 1).should be_within(0.001).of(3.277) # 3.27714473299218
        model_e.plain_idf('moon', 1, 1).should == default # returns 0 for stopwords
        model_e.plain_idf('said', 1, 1).should be_within(0.001).of(2.178) # 2.17853244432407
      end
    end

    # @see https://github.com/reddavis/TF-IDF/blob/master/spec/tf_idf_spec.rb
    context 'comparing to tf_idf gem' do
      let :one do
        build_document('a a a a a a a a b b')
      end

      let :two do
        build_document('a a')
      end

      let :model do
        build_model([one, two])
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
        model.tfidf(one, 'b').should be_within(0.001).of(1.414)
      end
    end
  end
end
