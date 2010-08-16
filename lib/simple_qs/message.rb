module SimpleQS
  class Message

    class DoubleSendError    < StandardError; end
    class NotReceivedError  < StandardError; end

    attr_accessor :queue
    attr_reader :message_id, :receipt_handle, :body, :md5_of_body
    attr_reader :sender_id, :sent_timestamp, :approximate_receive_count, :approximate_first_receive_timestamp

    def initialize(queue, params = nil)
      @queue = queue

      @body = params if params.class == String
      _from_responce(params) if params.class == SimpleQS::Responce
      _from_hash(params) if params.class == Hash
    end

    def send
      raise DoubleSendError, "Cann't send already sent message. Use resend() method." if message_id
      raise DoubleSendError, "Cann't send received message. Use resend() method." if receipt_handle

      params = {
        'Action'      => 'SendMessage',
        'MessageBody'  => body
      }
      request = queue.build_request(:post, params)
      responce = request.perform
      raise responce.to_error unless responce.successful?
      _from_responce(responce)

      self
    end

    def resend
      dup.send
    end

    def delete
      raise NotReceivedError, "Cann't delete message that was not received" unless receipt_handle
      params = {
        'Action'        => 'DeleteMessage',
        'ReceiptHandle'  => receipt_handle
      }
      request = queue.build_request(:get, params)
      responce = request.perform
      raise responce.to_error unless responce.successful?
    end
    alias_method :destroy, :delete

    def change_visibility(visibility_timeout)
      SimpleQS::Queue.check_visibility_timeout(visibility_timeout)
      raise NotReceivedError, "Cann't change visibility timeout for message that was not received" unless receipt_handle

      params = {
        'Action'            => 'ChangeMessageVisibility',
        'ReceiptHandle'      => receipt_handle,
        'VisibilityTimeout'  => visibility_timeout
      }

      request = queue.build_request(:get, params)
      responce = request.perform
      
      raise responce.to_error unless responce.successful?
    end

    def dup
      self.class.new(queue, body)
    end

    def ==(other)
      message_id == other.message_id && receipt_handle == other.receipt_handle
    end

    class << self
      def send(queue, message_body)
        new(queue, message_body).send
      end

      def receive(queue, attributes = nil, max_number_of_messages = nil, visibility_timeout = nil)

        SimpleQS::Queue.check_visibility_timeout(visibility_timeout) if visibility_timeout
        if max_number_of_messages && !(1..10).include?(max_number_of_messages)
          raise ArgumentError, "Maximum number of messages should be in 1..10 range"
        end

        params = {
          'Action'    => 'ReceiveMessage'
        }

        if attributes
          attributes = [attributes] unless attributes.class == Array
          attributes.uniq!
          unless (attributes - [:All, :SenderId, :SentTimestamp, :ApproximateReceiveCount, :ApproximateFirstReceiveTimestamp]).empty?
            raise ArgumentError,\
              "Allowed attributes: :All, :SenderId, :SentTimestamp, :ApproximateReceiveCount, :ApproximateFirstReceiveTimestamp"
          end
          attributes.each_index do |i|
            params["AttributeName.#{i + 1}"] = attributes[i]
          end
        end
        params['MaxNumberOfMessages'] = max_number_of_messages if max_number_of_messages
        params['VisibilityTimeout'] = visibility_timeout if visibility_timeout

        request = queue.build_request(:get, params)
        responce = request.perform
        if responce.respond_to?(:message)
          messages = (responce.message.class == Array ? responce.message : [responce.message])
          messages.map {|message| new(queue, message)}
        else
          []
        end
      end
    end

    protected

    def _from_responce(responce)
      @message_id   = responce.message_id
      @md5_of_body  = responce.md5_of_message_body
    end

    def _from_hash(message)
      attributes = message.delete('Attribute')
      attributes.each do |attr|
        message[attr['Name']] = attr['Value']
      end if attributes
      message.each do |key, value|
        key = key.gsub(/([A-Z]+)/, '_\1').downcase.gsub(/^_/, '')
        instance_variable_set("@#{key}".to_sym, value) if respond_to?(key.to_sym)
      end
    end

  end
end
