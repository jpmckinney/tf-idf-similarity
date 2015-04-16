source 'https://rubygems.org'

gem 'rb-gsl', '~> 1.16.0.2' if ENV['MATRIX_LIBRARY'] == 'gsl'
gem 'narray', '~> 0.6.0.0' if ENV['MATRIX_LIBRARY'] == 'narray'
gem 'nmatrix', '~> 0.1.0.rc5' if ENV['MATRIX_LIBRARY'] == 'nmatrix' && RUBY_VERSION >= '1.9'

# Specify your gem's dependencies in the gemspec
gemspec
