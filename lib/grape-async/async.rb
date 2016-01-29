module Grape
  class Async < Grape::Middleware::Base
    
    def call!(env)
      @env = env
      call_with_async do
        begin
          super
        rescue Grape::Exceptions::ValidationErrors => err
          endpoint.status err.status
          endpoint.headers.merge! err.headers
          endpoint.body err.to_json
          endpoint.done
          [ endpoint.status, endpoint.headers, [endpoint.body] ]
        rescue Exception
          error($!)
        end
      end
    end
    
    def call_with_async(&block)
      if endpoint.async_route? && !async_io.nil?
        if endpoint.async_route?(:em)
          proc = lambda {
            EM.error_handler do |err|
              error(err)
            end
            EM.next_tick do
              endpoint.deferred_resp.callback do
                resp = endpoint.file || [endpoint.body]
                async_call [endpoint.status, endpoint.header, resp]
              end
              block.call
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
            result = block.call
            async_call result
          end
        end
        
        [-1, {}, []] # Return async response
        
      else
        block.call

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
    
    private
    
    def error(msg)
      body = { error: msg }.to_json
      endpoint.status 500
      endpoint.body body
      endpoint.done
      [ endpoint.status, endpoint.headers, [endpoint.body] ]
    end

    
  end
end
