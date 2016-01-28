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
        
        use Grape::Async

        helpers do
          def log_start!(i)
            FakerAPI.requests << "start:#{i}"
          end
        
          def log_done!(i)
            FakerAPI.requests << "done:#{i}"
          end
        end
        
        async
        params do
          requires :counter, type: Integer
          requires :delay, type: Float
        end
        get :async do
          log_start!(params[:counter])
          sleep(params[:delay])
          present({ status: 'ok'})
          log_done!(params[:counter])
        end

        async :em
        params do
          requires :counter, type: Integer
          requires :delay, type: Float
        end
        get :async_em do
          log_start!(params[:counter])
          EM.add_timer(params[:delay]) do
            present({ status: 'ok'})
            done
            log_done!(params[:counter])
          end
        end

        params do
          requires :counter, type: Integer
        end
        get :sync do
          log_start!(params[:counter])
          present({ status: 'ok'})
          log_done!(params[:counter])
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
