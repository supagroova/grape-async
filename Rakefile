require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |config|
  config.pattern = 'spec/lib/**/*_spec.rb'
end

task default: [:spec]