# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'queue_it/version'

Gem::Specification.new do |spec|
  spec.name          = "queue_it"
  spec.version       = QueueIt::VERSION
  spec.authors       = ["Kasper Grubbe"]
  spec.email         = ["kawsper@gmail.com"]
  spec.description   = %q{Gem to handle the implementation of http://queue-it.net!}
  spec.summary       = %q{Gem to handle the implementation of http://queue-it.net}
  spec.homepage      = "https://github.com/gfish/queue_it"
  spec.license       = "GNU/GPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "addressable"
  spec.add_runtime_dependency "faraday", "~> 0.9.1"
  spec.add_runtime_dependency "faraday_middleware", "~> 0.9.1"
  spec.add_runtime_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "webmock"
end
