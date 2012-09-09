class TfIdfSimilarity::Document
  # Returns the term count.
  #
  # @note SMART n, Salton t, Chisholm FREQ
  def plain_term_frequency(term)
    term_count term
  end
  alias :plain_tf, :plain_term_frequency

  # Returns 1 if the term is present, 0 otherwise.
  #
  # @note SMART b, Salton b, Chisholm BNRY
  def binary_term_frequency(term)
    count = term_count term
    if count > 0
      1
    else
      0
    end
  end
  alias_method :binary_tf, :binary_term_frequency

  # Normalizes the term count by the maximum term count.
  #
  # @see http://en.wikipedia.org/wiki/Tf*idf
  def normalized_term_frequency(term)
    term_count(term) / maximum_term_count
  end
  alias_method :normalized_tf, :normalized_term_frequency

  # Further normalizes the normalized term frequency to lie between 0.5 and 1.
  #
  # @note SMART a, Salton n, Chisholm ATF1
  def augmented_normalized_term_frequency(term)
    0.5 + 0.5 * normalized_term_frequency(term)
  end
  alias_method :augmented_normalized_tf, :augmented_normalized_term_frequency

  # @note Chisholm ATFA 
  def augmented_average_term_frequency(term)
    count = term_count term
    if count > 0
      0.9 + 0.1 * count / average_term_count
    else
      0
    end
  end
  alias_method :augmented_average_tf, :augmented_average_term_frequency

  # @note Chisholm ATFC
  def changed_coefficient_augmented_normalized_term_frequency(term)
    count = term_count term
    if count > 0
      0.2 + 0.8 * count / maximum_term_count
    else
      0
    end
  end
  alias_method :changed_coefficient_augmented_normalized_tf, :changed_coefficient_augmented_normalized_term_frequency

  # Dampen the term count using log.
  #
  # @note SMART l, Chisholm LOGA
  def log_term_frequency(term)
    count = term_count term
    if count > 0
      1 + Math.log2(count)
    else
      0
    end
  end
  alias_method :log_tf, :log_term_frequency

  # Dampen and normalize the term count by the average term count.
  #
  # @note SMART L, Chisholm LOGN
  def normalized_log_term_frequency(term)
    count = term_count term
    if count > 0
      (1 + Math.log2(count)) / (1 + Math.log2(average_term_count))
    else
      0
    end
  end
  alias_method :normalized_log_tf, :normalized_log_term_frequency

  # @note Chisholm LOGG
  def augmented_log_term_frequency(term)
    count = term_count term
    if count > 0
      0.2 + 0.8 * Math.log(count + 1)
    else
      0
    end
  end
  alias_method :augmented_log_tf, :augmented_log_term_frequency

  # Dampen the term count using square root.
  #
  # @note Chisholm SQRT
  def square_root_term_frequency(term)
    count = term_count term
    if count > 0
      Math.sqrt(count - 0.5) + 1
    else
      0
    end
  end
  alias_method :square_root_tf, :square_root_term_frequency
end
