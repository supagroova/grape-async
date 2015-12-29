module Grape
  class API

    class << self
      def async(method = :threaded)
        route_setting :async, { async: true, async_method: method }
      end
    end
  end

end