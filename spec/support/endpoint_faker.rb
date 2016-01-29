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
          
          def delay
            (params[:delay] || 0.5).to_f
          end

          def counter
            (params[:counter] || 1).to_i
          end

        end
        
        async
        params do
          optional :counter, type: Integer
          optional :delay, type: Float
        end
        get :async do
          log_start!(counter)
          sleep(delay)
          present({ status: 'ok'})
          log_done!(counter)
        end

        async :em
        params do
          optional :counter, type: Integer
          optional :delay, type: Float
        end
        get :async_em do
          log_start!(counter)
          EM.add_timer(delay) do
            present({ status: 'ok'})
            done
            log_done!(counter)
          end
        end

        params do
          optional :counter, type: Integer
        end
        get :sync do
          log_start!(counter)
          present({ status: 'ok'})
          log_done!(counter)
        end

        params do
          requires :counter, type: Integer
        end
        get :async_error do
          sleep(delay)
          raise RuntimeError.new "Booom!"
        end

        async :em
        params do
          requires :counter, type: Integer
        end
        get :async_em_error do
          EM.add_timer(delay) do
            raise RuntimeError.new "Booom!"
          end
        end

        params do
          requires :counter, type: Integer
        end
        get :sync_error do
          raise RuntimeError.new "Booom!"
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
