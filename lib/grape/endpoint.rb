module Grape
  class Endpoint

    if defined?(EventMachine)
      class DeferrableResp
        include EventMachine::Deferrable
      end
    end

    def deferred_resp
      @deferred_resp ||= DeferrableResp.new if async_route?(:em)
    end
    
    def async_route?(method = nil)
      async_settings = route_setting(:async) || {}
      async = async_settings.fetch(:async, false)
      async_method = async_settings.fetch(:async_method, :threaded)
      if method
        async && async_method == method.to_sym
      else
        async
      end
    end
    
    def done
      if deferred_resp.is_a?(DeferrableResp)
        deferred_resp.set_deferred_status :succeeded
      end
    end

  end
end