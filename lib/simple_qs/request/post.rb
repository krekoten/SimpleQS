module SimpleQS
  module Request
    class Post < Base
      http_method :post

			def perform
				sign!
				SimpleQS::Responce.new Net::HTTP.post_form(URI.parse(uri), query_params).body
			end
    end
  end
end
