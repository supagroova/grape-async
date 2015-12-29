$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'grape-async'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end