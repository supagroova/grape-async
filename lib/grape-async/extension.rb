module Grape
  class Async
    module Extension

      def async(method = :threaded)
        route_setting :async, { async: true, async_method: method }
      end
      
      Grape::API.extend self
      
    end
  end
end