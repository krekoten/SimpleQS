module SimpleQS
  module Request
    class Get < Base
      http_method :get
      
      def perform
				sign!
        SimpleQS::Responce.new Net::HTTP.get(URI.parse(uri(true)))
      end
    end
  end
end
