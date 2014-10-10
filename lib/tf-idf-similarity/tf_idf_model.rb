# A document-term matrix using the tf*idf function.
#
# @see http://lucene.apache.org/core/4_0_0-BETA/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html
module TfIdfSimilarity
  class TfIdfModel < Model
    # Return the term's inverse document frequency.
    #
    # @param [String] term a term
    # @return [Float] the term's inverse document frequency
    def inverse_document_frequency(term)
      df = @model.document_count(term)
      1 + log(documents.size / (df + 1.0))
    end
    alias_method :idf, :inverse_document_frequency

    # Returns the term's frequency in the document.
    #
    # @param [Document] document a document
    # @param [String] term a term
    # @return [Float] the term's frequency in the document
    def term_frequency(document, term)
      tf = document.term_count(term)
      sqrt(tf)
    end
    alias_method :tf, :term_frequency
  end
end
