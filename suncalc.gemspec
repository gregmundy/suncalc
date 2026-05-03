# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'suncalc/version'

Gem::Specification.new do |spec|
  spec.name          = "suncalc"
  spec.version       = SunCalc::VERSION
  spec.authors       = ["Greg Mundy"]
  spec.email         = ["greg@gregmundy.com"]
  spec.summary       = %q{Ruby port of Vladimir Agafonkin's excellent suncalc.js library.}
  spec.description   = %q{A Ruby library for calculating sun/moon positions and phases.}
  spec.homepage      = "https://github.com/gregmundy/suncalc"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
end
