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
        status, headers, body = result
        begin
          async_io.write("HTTP/1.1 #{status}\r\n")
          headers.each do |key, value|
            async_io.write("#{key}: #{value}\r\n")
          end
          async_io.write("Connection: close\r\n")
          async_io.write("\r\n")
          body.each do |data|
            async_io.write(data)
          end
        ensure
          async_io.close
        end
      end
    end
    
    def async_io
      @async_io ||= @env['async.callback'] || begin
        @env.key?('rack.hijack') ? @env['rack.hijack'].call : nil
      end
    end
    
    def endpoint
      @env[Grape::Env::API_ENDPOINT]
    end
    
  end
end
