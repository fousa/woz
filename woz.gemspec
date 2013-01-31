# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'woz/version'

Gem::Specification.new do |gem|
  gem.name          = "woz"
  gem.version       = Woz::VERSION
  gem.authors       = ["Jelle Vandebeeck"]
  gem.email         = ["jelle@fousa.be"]
  gem.description   = %q{Generate strings files from an xls and vice versa.}
  gem.summary       = %q{Easy strings file generate.}
  gem.homepage      = "http://github.com/fousa/woz"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'highline', '1.6.15'
  gem.add_dependency 'thor', '0.16.0'
  gem.add_dependency 'spreadsheet', '0.7.3'
end
