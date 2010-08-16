module SimpleQS
  class Responce
    class FailureBuilder
      def self.build responce
        responce.instance_eval do
          def sender_error?
            @xml_data[root_element]['Error']['Type'] == 'Sender'
          end

          def receiver_error?
            @xml_data[root_element]['Error']['Type'] == 'Receiver'
          end

          def request_id
            @xml_data[root_element]['RequestId']
          end

          def error_code
            @xml_data[root_element]['Error']['Code'].gsub(/\./, '')
          end
          
          def error_message
            @xml_data[root_element]['Error']['Message']
          end

          def to_error
            self.class.const_get(error_code =~ /Error$/ ? error_code : "#{error_code}Error").new error_message
          end
        end
      end
    end
  end
end
