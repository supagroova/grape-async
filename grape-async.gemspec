# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "grape-async"
  spec.version       = '0.1.0'
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Lachlan Laycock"]
  spec.email         = ["l.laycock@stuart.com"]
  spec.description   = %q{Async endpoints for Grape APIs}
  spec.summary       = %q{Enable asyncronous endpoints to avoid blocking slow requests within EventMachine or Threads}
  spec.homepage      = "https://github.com/stuart/grape-async"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "grape"
  spec.add_dependency "eventmachine"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.2', '< 4'
end
