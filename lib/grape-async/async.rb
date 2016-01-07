module Grape
  class Async < Grape::Middleware::Base
    
    def call!(env)
      @env = env
      if endpoint.async_route? && !async_io.nil?
        if endpoint.async_route?(:em)
          proc = lambda {
            EM.next_tick do
              super
              endpoint.deferred_resp.callback do
                resp = endpoint.file || [endpoint.body]
                async_call [endpoint.status, endpoint.header, resp]
              end
            end
          }
          if !EM.reactor_running?
            EM.run do
              proc.call
            end
          else
            proc.call
          end
        else
          Thread.new do
            result = super
            async_call result
            yield
          end
        end
        
        [-1, {}, []] # Return async response
        
      else
        super

      end
    end
    
    def async_call(result)
      if @env['async.callback']
        async_io.call result
      elsif @env['rack.hijack']
        begin
          if result.last.is_a?(Rack::BodyProxy)
            async_io << result.last.body.first
            result.last.close unless result.last.closed?
          elsif result.last.is_a?(Array)
            async_io << result.last.first
          end
        ensure
          EM.stop if endpoint.async_route?(:em)
          @env['rack.hijack'].close
        end
      end
    end
    
    def async_io
      @env['async.callback'] || begin
        @env.key?('rack.hijack') ? @env['rack.hijack'].call : nil
      end
    end
    
    def endpoint
      @env[Grape::Env::API_ENDPOINT]
    end
    
  end
end
