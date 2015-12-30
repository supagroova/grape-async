require 'eventmachine'
require 'pry'

module Spec
  module Support
    class EndpointFaker
      
      class FakerAPI < Grape::API

        class << self
          
          def requests
            @@requests ||= []
          end
          
          def clear_requests!
            requests.clear
          end
          
        end
        
        logger = Logger.new('log/app.log')
        use Grape::Middleware::Async
        use Rack::CommonLogger
        
        helpers do
          def logger
            API.logger
          end
              
          def log_before!
            FakerAPI.requests << "start"
          end
        
          def log_done!
            FakerAPI.requests << "done"
          end
        end
        
        async
        get :async do
          log_before!
          sleep(0.5)
          present({ status: 'ok'})
          log_done!
        end

        async :em
        get :async_em do
          log_before!
          EM.add_timer(0.5) do
            present({ status: 'ok'})
            done
            log_done!
          end
        end

        get :sync do
          log_before!
          present({ status: 'ok'})
          log_done!
        end

      end

      def initialize(app, endpoint = FakerAPI.endpoints.first)
        @app = app
        @endpoint = endpoint
      end

      def call(env)
        @endpoint.instance_exec do
          @request = Grape::Request.new(env.dup)
        end

        @app.call(env.merge('api.endpoint' => @endpoint))
      end
    end
  end
end
