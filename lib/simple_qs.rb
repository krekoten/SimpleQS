require 'rubygems'

$: << File.join(File.dirname(__FILE__))

module SimpleQS
  
  API_VERSION = '2009-02-01'
  
  SQS_HOSTS = {
    :default    => 'queue.amazonaws.com',
    :us_west_1  => 'us-west-1.queue.amazonaws.com',
    :eu_west_1  => 'eu-west-1.queue.amazonaws.com'
  }

  autoload :Message,    'simple_qs/message'
  autoload :Queue,      'simple_qs/queue'
  autoload :Request,    'simple_qs/request'
  autoload :Responce,   'simple_qs/responce'
  
  class << self
    attr_accessor :access_key_id, :secret_access_key
    
    def account_id=(value)
      @account_id = value.gsub(/[^0-9]/, '')
    end
    attr_reader :account_id
    
    def host=(value)
      raise ArgumentError, 'Expected value to be one of: :default, :us_west_1, :eu_west_1' unless SQS_HOSTS.key?(value)
      @host = value
    end
    
    def host
      @host ||= :default
      SQS_HOSTS[@host]
    end
  end
end

require 'version'
