require 'tf-idf-similarity/document'

# @todo http://nlp.stanford.edu/IR-book/html/htmledition/maximum-tf-normalization-1.html
#
# @note The treat, tf_idf, similarity and rsemantic gems normalizes to the number of terms in the document.
# @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L77
# @see https://github.com/reddavis/TF-IDF/blob/master/lib/tf_idf.rb#L76
# @see https://github.com/bbcrd/Similarity/blob/master/lib/similarity/document.rb#L42
# @see https://github.com/josephwilk/rsemantic/blob/master/lib/semantic/transform/tf_idf_transform.rb#L17
#
# @note The tf-idf gem normalizes to the number of unique terms in the document.
# @see https://github.com/mchung/tf-idf/blob/master/lib/tf-idf.rb#L172
#
# @see http://nlp.stanford.edu/IR-book/html/htmledition/document-and-query-weighting-schemes-1.html
# @see http://www.cs.odu.edu/~jbollen/IR04/readings/article1-29-03.pdf
# @see http://www.sandia.gov/~tgkolda/pubs/bibtgkfiles/ornl-tm-13756.pdf
class TfIdfSimilarity::Document
  # @return [Float] the maximum term count of any term in the document
  def maximum_term_count
    @maximum_term_count ||= @term_counts.values.max.to_f
  end

  # @return [Float] the average term count of all terms in the document
  def average_term_count
    @average_term_count ||= @term_counts.values.reduce(:+) / @term_counts.size.to_f
  end

  # Returns the term count.
  # @see https://github.com/mkdynamic/vss/blob/master/lib/vss/engine.rb#L75
  # @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L11
  #
  # SMART n, Salton t, Chisholm FREQ
  def plain_term_frequency(term)
    term_counts[term]
  end
  alias :plain_tf, :plain_term_frequency

  # Returns 1 if the term is present, 0 otherwise.
  #
  # SMART b, Salton b, Chisholm BNRY
  def binary_term_frequency(term)
    count = term_counts[term]
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
    term_counts[term] / maximum_term_count
  end
  alias_method :normalized_tf, :normalized_term_frequency

  # Further normalizes the normalized term frequency to lie between 0.5 and 1.
  #
  # SMART a, Salton n, Chisholm ATF1
  def augmented_normalized_term_frequency(term)
    0.5 + 0.5 * normalized_term_frequency(term)
  end
  alias_method :augmented_normalized_tf, :augmented_normalized_term_frequency

  # Chisholm ATFA
  def augmented_average_term_frequency(term)
    count = term_counts[term]
    if count > 0
      0.9 + 0.1 * count / average_term_count
    else
      0
    end
  end
  alias_method :augmented_average_tf, :augmented_average_term_frequency

  # Chisholm ATFC
  def changed_coefficient_augmented_normalized_term_frequency(term)
    count = term_counts[term]
    if count > 0
      0.2 + 0.8 * count / maximum_term_count
    else
      0
    end
  end
  alias_method :changed_coefficient_augmented_normalized_tf, :changed_coefficient_augmented_normalized_term_frequency

  # @see https://github.com/louismullie/treat/blob/master/lib/treat/workers/extractors/tf_idf/native.rb#L12
  #
  # SMART l, Chisholm LOGA
  def log_term_frequency(term)
    count = term_counts[term]
    if count > 0
      1 + Math.log(count)
    else
      0
    end
  end
  alias_method :log_tf, :log_term_frequency

  # SMART L, Chisholm LOGN
  def normalized_log_term_frequency(term)
    count = term_counts[term]
    if count > 0
      (1 + Math.log(count)) / (1 + Math.log(average_term_count))
    else
      0
    end
  end
  alias_method :normalized_log_tf, :normalized_log_term_frequency

  # Chisholm LOGG
  def augmented_log_term_frequency(term)
    count = term_counts[term]
    if count > 0
      0.2 + 0.8 * Math.log(count + 1)
    else
      0
    end
  end
  alias_method :augmented_log_tf, :augmented_log_term_frequency

  # Chisholm SQRT
  def square_root_term_frequency(term)
    count = term_counts[term]
    if count > 0
      Math.sqrt(count - 0.5) + 1
    else
      0
    end
  end
  alias_method :square_root_tf, :square_root_term_frequency
end
