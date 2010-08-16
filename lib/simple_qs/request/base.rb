require 'uri'
require 'net/http'
require 'base64'
require 'hmac-sha1'

module SimpleQS
  module Request
    class Base
      
      RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/
      SIGNATURE_VERSION   = 2
      SIGNATURE_METHOD    = 'HmacSHA1'
      
      def initialize(params = {})
        self.query_params = params
      end
      
      def ==(other)
        self.class.http_method == other.class.http_method\
          && query_params == other.query_params\
          && query_string == other.query_string
      end

      def timestamp
        @timestamp ||= _timestamp
      end
      
      def timestamp=(time)
        raise ArgumentError, "expected Time object, bug got #{time.class.to_s} instead." unless time.kind_of?(Time)
        @timestamp = time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      end

      def query_params
        @query_params ||= {}
        @query_params = {
          'SignatureVersion'    => SIGNATURE_VERSION,
          'SignatureMethod'     => SIGNATURE_METHOD,
          'Version'             => SimpleQS::API_VERSION,
          'Timestamp'           => timestamp,
          'AWSAccessKeyId'      => SimpleQS.access_key_id
        }.merge(@query_params)
        @query_params.delete('Timestamp') if @query_params['Expires']
        
        @query_params
      end
      attr_writer :query_params
      
      def update_query_params(params)
        @query_params = query_params.merge params
      end

      def query_string
        @query_string ||= "/"
      end
      
      def query_string=(value)
        value = value.join('/') if value.kind_of?(Array)
        @query_string = (value =~ /^\// ? value : "/#{value}")
      end

      # Canonicalizes query string
      def canonical_query_string
        params_to_query(query_params.sort)
      end

      def signature_base_string
        [
          self.class.http_method.to_s.upcase,
          SimpleQS.host.downcase,
          query_string,
          canonical_query_string
        ].join("\n")
      end

      def uri(with_query_params = false)
        "http://#{SimpleQS.host}#{query_string}" << (with_query_params ? "?#{params_to_query(query_params)}" : '')
      end
      
      def sign!
        update_query_params({
          'Signature'   => Base64.encode64(HMAC::SHA1.digest(SimpleQS.secret_access_key, signature_base_string)).chomp
        })
        self
      end

      def params_to_query(params)
        params.map {|pair| pair.map {|value| URI.escape(value.to_s, RESERVED_CHARACTERS)}.join('=')}.join('&')
      end
      
      class << self
        def http_method(value = nil)
          @http_method = value if value
          @http_method
        end
      end
      
      protected

      # Generates UTC timestamp in dateTime object format
      def _timestamp
        Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
  end
end
