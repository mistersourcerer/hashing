# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hashing/version'

Gem::Specification.new do |spec|
  spec.name          = "hashing"
  spec.version       = Hashing::VERSION
  spec.authors       = ["Ricardo Valeriano"]
  spec.email         = ["ricardo.valeriano@gmail.com"]
  spec.summary       = %q{Serialize your objects into Hashes}
  spec.description   = %q{Provides an easy way to specify which instances vars of your objects should be used as `key` in a Hash returned by the `#to_h` method. Also gives you a `YourClass::from_hash` to reconstruct the instances.}
  spec.homepage      = "http://github.com/ricardovaleriano/hashing"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
end
