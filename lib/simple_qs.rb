require 'rubygems'

$: << File.join(File.dirname(__FILE__))

module SimpleQS
  
  API_VERSION = '2009-02-01'

	autoload :Message,		'simple_qs/message'
  autoload :Queue,      'simple_qs/queue'
  autoload :Request,    'simple_qs/request'
  autoload :Responce,   'simple_qs/responce'
  
  class << self
    attr_accessor :access_key_id, :secret_access_key
    
    def account_id= value
      @account_id = value.gsub(/[^0-9]/, '')
    end
    attr_reader :account_id
  end
end

require 'version'
