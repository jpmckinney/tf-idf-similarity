source "http://rubygems.org"

gem 'gsl', '~> 1.14.5' if ENV['MATRIX_LIBRARY'] == 'gsl'
gem 'narray', '~> 0.6.0.0' if ENV['MATRIX_LIBRARY'] == 'narray'
gem 'nmatrix', '~> 0.0.3' if ENV['MATRIX_LIBRARY'] == 'nmatrix' && RUBY_VERSION >= '1.9'

# Specify your gem's dependencies in the gemspec
gemspec
