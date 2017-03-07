# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tf-idf-similarity/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "tf-idf-similarity"
  s.version     = TfIdfSimilarity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James McKinney"]
  s.homepage    = "https://github.com/jpmckinney/tf-idf-similarity"
  s.summary     = %q{Calculates the similarity between texts using tf*idf}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('unicode_utils', '~> 1.4')

  s.add_development_dependency('coveralls')
  s.add_development_dependency('json', '< 2')
  s.add_development_dependency('rake', '< 12')
  s.add_development_dependency('rspec', '~> 2.10')
end
