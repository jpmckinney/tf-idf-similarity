require 'rubygems'
require 'rspec'
require File.dirname(__FILE__) + '/../lib/tf-idf-similarity'

MATRIX_LIBRARY = (ENV['MATRIX_LIBRARY'] || :matrix).to_sym
puts "\n==> Running specs with #{MATRIX_LIBRARY}"

case MATRIX_LIBRARY
when :gsl
  require 'gsl'
when :narray
  require 'narray'
when :nmatrix
  require 'nmatrix'
else
  require 'matrix'
end
