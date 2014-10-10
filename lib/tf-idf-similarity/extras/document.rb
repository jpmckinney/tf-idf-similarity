module TfIdfSimilarity
  class Document
    # @return [Float] the maximum term count of any term in the document
    def maximum_term_count
      @maximum_term_count ||= term_counts.values.max.to_f
    end

    # @return [Float] the average term count of all terms in the document
    def average_term_count
      @average_term_count ||= term_counts.values.reduce(0, :+) / term_counts.size.to_f
    end
  end
end
