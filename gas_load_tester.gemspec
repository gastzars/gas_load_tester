# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gas_load_tester/version'

Gem::Specification.new do |spec|
  spec.name          = "gas_load_tester"
  spec.version       = GasLoadTester::VERSION
  spec.authors       = ["Tanapat Sainak"]
  spec.email         = ["fallen_things@hotmail.com"]

  spec.summary       = %q{Ruby load test library.}
  spec.description   = %q{Simple Ruby load test library.}
  spec.homepage      = "https://github.com/gastzars/gas_load_tester"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'ruby-progressbar', '~> 1.8.1'
  spec.add_runtime_dependency 'chartkick', '~> 2.2.2'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
