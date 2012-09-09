# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tf-idf-similarity/version"

Gem::Specification.new do |s|
  s.name        = "tf-idf-similarity"
  s.version     = TfIdfSimilarity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Open North"]
  s.email       = ["info@opennorth.ca"]
  s.homepage    = "http://github.com/opennorth/tf-idf-similarity"
  s.summary     = %q{Implements a Vector Space Model (VSM) with tf*idf weights}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('unicode_utils')
  s.add_development_dependency('rspec', '~> 2.10')
  s.add_development_dependency('rake')
end
