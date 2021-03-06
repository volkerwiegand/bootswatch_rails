# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bootswatch_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "bootswatch_rails"
  spec.version       = BootswatchRails::VERSION
  spec.authors       = ["Volker Wiegand"]
  spec.email         = ["volker.wiegand@cvw.de"]
  spec.summary       = "Add bootswatch.com themes to the Rails asset pipeline"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/volkerwiegand/bootswatch_rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'
  spec.add_dependency 'railties', '>= 4.0'
  spec.add_dependency 'bootstrap-sass', '~> 3.1'
  spec.add_dependency 'enumerize', '~> 2.0'
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", ">= 10.1"
end
