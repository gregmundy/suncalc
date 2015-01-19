# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'suncalc/version'

Gem::Specification.new do |spec|
  spec.name          = "suncalc"
  spec.version       = Suncalc::VERSION
  spec.authors       = ["Greg Mundy"]
  spec.email         = ["gregmundy@gmail.com"]
  spec.summary       = %q{Ruby port of Vladimir Agafonkin's excellent suncalc.js library.}
  spec.description   = %q{A Ruby library for calculating sun/moon positions and phases.}
  spec.homepage      = "https://bitbucket.org/greg_mundy/suncalc.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
