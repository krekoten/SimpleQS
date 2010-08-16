module SimpleQS
  module Request
    autoload :Base,     'simple_qs/request/base'
    autoload :Get,      'simple_qs/request/get'
    autoload :Post,     'simple_qs/request/post'
    
    class UnknownHttpMethod < StandardError; end
    
    HTTP_METHODS = {
      :get    => :Get,
      :post   => :Post
    }
    
    class << self
      def build(request, params = {})
        if SimpleQS::Request::HTTP_METHODS.keys.include?(request)
          SimpleQS::Request.const_get(HTTP_METHODS[request]).new(params)
        else
          raise SimpleQS::Request::UnknownHttpMethod, "Method #{request} is unknown or unsupported"
        end
      end
    end
  end
end
