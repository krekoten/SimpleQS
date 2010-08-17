module SimpleQS
  class Queue
    
    class MaxVisibilityError < StandardError; end

    MAX_VISIBILITY_TIMEOUT = 43200

    attr_accessor :queue_url

    # Initializes new SimpleQS::Queue object
    # Parameters:
    #    queue_url_or_name - String, either queue url or queue name
    def initialize(queue_url_or_name)
      begin
        self.class.check_queue_name(queue_url_or_name)
        @name = queue_url_or_name
        @queue_url = "http://#{SimpleQS.host}/#{SimpleQS.account_id}/#{@name}"
      rescue ArgumentError
        @queue_url = queue_url_or_name
      end
    end

    # Get queue name
    # Returns:
    #    String - queue name
    def name
      @name ||= @queue_url.split(/\//).last
    end

    # Is this queue deleted?
    #  Returns:
    #    Bool - true if queue is deleted
    def deleted
      @deleted ||= false
    end
    alias_method :deleted?, :deleted


    # Deletes this queue
    # Returns:
    #    Bool - true, if successful
    # Raises:
    #    SimpleQS::Responce::Error
    def delete
      params = {
        'Action'    => 'DeleteQueue'
      }

      request = build_request(:get, params)
      responce = request.perform
      
      raise responce.to_error unless responce.successful?

      @deleted = true
    end
    alias_method :destroy, :delete

    def send_message(body)
      SimpleQS::Message.send(self, body)
    end

    def receive_messages(attributes = nil, max_number_of_messages = nil, visibility_timeout = nil)
      SimpleQS::Message.receive(self, attributes, max_number_of_messages, visibility_timeout)
    end

    def get_attributes(attribute_or_array = nil)
      params = {
        'Action'    => 'GetQueueAttributes'
      }

      if attribute_or_array
        attribute_or_array = [attribute_or_array] unless attribute_or_array.class == Array
        attribute_or_array.uniq!
        unless (attribute_or_array - [:All, :ApproximateNumberOfMessages, :ApproximateNumberOfMessagesNotVisible,
              :VisibilityTimeout, :CreatedTimestamp, :LastModifiedTimestamp, :Policy]).empty?
          raise ArgumentError,\
            "Allowed attributes: :All, :ApproximateNumberOfMessages, :ApproximateNumberOfMessagesNotVisible, " <<
              ":VisibilityTimeout, :CreatedTimestamp, :LastModifiedTimestamp, :Policy"
        end
        attribute_or_array.each_index do |i|
          params["AttributeName.#{i + 1}"] = attribute_or_array[i]
        end
      end

      request = build_request(:get, params)
      responce = request.perform
      raise responce.to_error unless responce.successful?

      if responce.respond_to?(:attribute)
        responce.attribute.inject({}) do |result, key_value|
          result[key_value['Name']] = key_value['Value']
          result
        end
      else
        {}
      end
    end

    def set_visibility_timeout(visibility_timeout)
      set_attributes({:VisibilityTimeout => visibility_timeout})
    end
    
    def set_policy(policy)
      set_attributes({:Policy => policy})
    end

    def set_attributes(attributes)
      raise ArgumentError, "Allowed attributes: :VisibilityTimeout, :Policy" unless (attributes.keys - [:VisibilityTimeout, :Policy]).empty?
      self.class.check_visibility_timeout(attributes[:VisibilityTimeout]) if attributes[:VisibilityTimeout]

      params = {
        'Action'      => 'SetQueueAttributes'
      }

      i = 1
      attributes.each do |key, value|
        params["Attribute.#{i}.Name"] = key.to_s
        params["Attribute.#{i}.Value"] = value
        i += 1
      end

      request = build_request(:get, params)
      responce = request.perform

      raise responce.to_error unless responce.successful?
    end

    # label - String, identifier for permissions
    # permissions - Array of Hashes, [{:account_id => '125074342641', :action => 'SendMessage'}, ...]
    def add_permissions(label, permissions)
      self.class.check_queue_name(label)

      params = {
        'Action'  => 'AddPermission',
        'Label'    => label
      }

      i = 1
      permissions.each do |permission_hash|
        raise ArgumentError, "invalid action: #{permission_hash[:action]}"\
          unless ['*', 'SendMessage', 'ReceiveMessage', 'DeleteMessage',
                  'ChangeMessageVisibility', 'GetQueueAttributes'].include?(permission_hash[:action])

        params["AWSAccountId.#{i}"] = permission_hash[:account_id]
        params["ActionName.#{i}"]    = permission_hash[:action]
        i += 1
      end

      request = build_request(:post, params)
      responce = request.perform

      raise responce.to_error unless responce.successful?
    end

    def remove_permissions(label)
      params = {
        'Action'  => 'RemovePermission',
        'Label'    => label
      }

      request = build_request(:get, params)
      responce = request.perform

      raise responce.to_error unless responce.successful?
    end

    def build_request(method, params)
      request = SimpleQS::Request.build(method, params)
      request.query_string = [SimpleQS.account_id, name]
      request
    end
    
    class << self
      # Create new queue
      # Parameters:
      #    name - String, name of queue. Should be not longer than 80 chars and contain only a-zA-Z0-9\-\_
      #    default_visibility_timeout - Fixnum, visibility timeout [Optional]. In range 0 to MAX_VISIBILITY_TIMEOUT.
      #                                 If nil, then default is used (30 seconds).
      #    &block - if given, then newly created queue object passed to it
      #  Returns:
      #    SimpleQS::Queue
      #  Raises:
      #    ArgumentError
      #    SimpleQS::Queue::MaxVisibilityError
      #    SimpleQS::Responce::Error
      def create(name, default_visibility_timeout = nil, &block)
        
        check_queue_name(name)
        check_visibility_timeout(default_visibility_timeout)
        
        params = {
          'Action'    => 'CreateQueue',
          'QueueName' => name
        }
        params['DefaultVisibilityTimeout'] = default_visibility_timeout if default_visibility_timeout
        
        request = SimpleQS::Request.build(:get, params)
        responce = request.perform
        if responce.successful?
          queue = new(responce.queue_url)
          yield queue if block_given?
          queue
        else
          raise responce.to_error
        end
      end

      # List queues
      # Parameters:
      #    pattern - String, first letterns of queues names [Optional].
      # Returns:
      #    Array - array of SimpleQS::Queue or empty if nothing found
      #  Rises:
      #    ArgumentError
      #    SimpleQS::Responce::Error
      def list(pattern = nil)
        params = {
          'Action'    => 'ListQueues'
        }

        check_queue_name(pattern) if pattern
        params['QueueNamePrefix'] = pattern if pattern

        request = SimpleQS::Request.build(:get, params)
        responce = request.perform
        raise responce.to_error unless responce.successful?

        begin
          queues = responce.queue_url.class == Array ? responce.queue_url : [responce.queue_url]
          queues.map {|queue_url| new(queue_url)}
        rescue NoMethodError
          []
        end
      end
      
      def exists?(queue_name)
        list(queue_name).any? {|queue| queue.name == queue_name}
      end
      
      def delete(queue_name)
        new(queue_name).delete
      end
      alias_method :destroy, :delete
      
      # Performs checks on queue name. Raises ArgumentError with message in case of
      # constraint violation
      def check_queue_name(name)
        raise ArgumentError, "expected to be String, but got #{name.class.to_s}" unless name.class == String
        raise(
          ArgumentError,
          "should be maximum 80 characters long"
        ) if name.length > 80
        raise(
          ArgumentError,
          "should contain only alphanumeric characters, hyphens (-), and underscores (_)"
        ) if name =~ /[^a-zA-Z0-9\_\-]/
      end
      
      # Performs checks on visibility timeout. Raises ArgumentError or SimpleQS::Queue::MaxVisibilityError
      # with message in case of constraint violation
      def check_visibility_timeout(default_visibility_timeout)
        raise(
          ArgumentError,
          "expected visibility timeout to respon to to_i, but #{default_visibility_timeout.class.to_s} doesn't"
        ) if default_visibility_timeout && default_visibility_timeout.class != Fixnum
        raise(
          MaxVisibilityError,
          "expected visibility timeout to be in 0...#{MAX_VISIBILITY_TIMEOUT} range, got #{default_visibility_timeout}"
        ) if default_visibility_timeout && !(0...MAX_VISIBILITY_TIMEOUT).include?(default_visibility_timeout)
      end
    end
  end
end
