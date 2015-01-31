# A document-term matrix using the BM25 function.
#
# @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/BM25Similarity.html
# @see https://en.wikipedia.org/wiki/Okapi_BM25
module TfIdfSimilarity
  class BM25Model < Model
    # Return the term's inverse document frequency.
    #
    # @param [String] term a term
    # @return [Float] the term's inverse document frequency
    def inverse_document_frequency(term)
      df = @model.document_count(term)
      log((documents.size - df + 0.5) / (df + 0.5))
    end
    alias_method :idf, :inverse_document_frequency

    # Returns the term's frequency in the document.
    #
    # @param [Document] document a document
    # @param [String] term a term
    # @return [Float] the term's frequency in the document
    #
    # @note Like Lucene, we use a b value of 0.75 and a k1 value of 1.2.
    def term_frequency(document, term)
      tf = document.term_count(term)
      (tf * 2.2) / (tf + 0.3 + 0.9 * documents.size / @model.average_document_size)
    end
    alias_method :tf, :term_frequency
  end
end
