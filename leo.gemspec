# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leo/version'

Gem::Specification.new do |gem|
  gem.name          = "leo"
  gem.version       = Leo::VERSION
  gem.authors       = ["Jelle Vandebeeck"]
  gem.email         = ["jelle@fousa.be"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'thor', '0.16.0'
  gem.add_dependency 'spreadsheet', '0.7.3'
end