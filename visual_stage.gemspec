# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'visual_stage/version'

Gem::Specification.new do |spec|
  spec.name          = "visual_stage"
  spec.version       = VisualStage::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = %q{Wrapper for vs2007}
  spec.description   = %q{This is a wrapper for vs2007.}
  spec.homepage      = "http://gitlab.misasa.okayama-u.ac.jp:gems/visual_stage"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "turnip", "~> 1.2"
end
