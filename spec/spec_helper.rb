$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'support'))

require 'rubygems'
require 'bundler'
require 'pry'
require 'rack/test'
require 'grape-async'
require 'endpoint_faker'

Bundler.setup :default, :test

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.raise_errors_for_deprecations!
  config.drb = true
  config.color = true
  # config.order = :random
  config.mock_with :rspec
  
  config.before(:suite) do
  end

  config.before(:each) do
    Grape::Util::InheritableSetting.reset_global!
  end
  
end