require 'rubygems'

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require File.dirname(__FILE__) + '/../lib/tf-idf-similarity'

MATRIX_LIBRARY = (ENV['MATRIX_LIBRARY'] || :matrix).to_sym
puts "\n==> Running specs with #{MATRIX_LIBRARY}"

case MATRIX_LIBRARY
when :gsl
  require 'gsl'
when :narray
  require 'narray'
when :numo
  require 'numo/narray'
when :nmatrix
  require 'nmatrix'
else
  require 'matrix'
end

RSpec.configure do |c|
  if MATRIX_LIBRARY == :gsl # GSL can't initialize an empty matrix
    c.filter_run_excluding :empty_matrix => true
  end
end
