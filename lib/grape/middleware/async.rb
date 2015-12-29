module Grape
  module Middleware
    class Async < Grape::Middleware::Base
      
      def call!(env)
        @env = env
        endpoint = @env[Grape::Env::API_ENDPOINT]

        if endpoint.async_route? && !async_io.nil?
          if endpoint.async_route?(:em)
            EventMachine.next_tick do
              super
              endpoint.deferred_resp.callback do
                resp = endpoint.file || [endpoint.body]
                async_io.call [endpoint.status, endpoint.header, resp]
              end
            end
          else
            Thread.new do
              result = super
              async_io.call result
              yield
            end
          end
          
          [-1, {}, []] # Return async response

        else
          super

        end
      end
      
      def async_io
        @env['async.callback'] || @env['rake.hijack']
      end
      
    end
  end
end