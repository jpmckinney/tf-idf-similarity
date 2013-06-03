require 'forwardable'
require 'set'

begin
  require 'unicode_utils'
rescue LoadError
  # Ruby 1.8
end

module TfIdfSimilarity
end

require 'tf-idf-similarity/matrix_methods'
require 'tf-idf-similarity/term_count_model'
require 'tf-idf-similarity/tf_idf_model'
require 'tf-idf-similarity/document'
require 'tf-idf-similarity/token'
