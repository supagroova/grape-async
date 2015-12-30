require './lib/grape-async'
require './spec/support/endpoint_faker'

run Spec::Support::EndpointFaker::FakerAPI.new
