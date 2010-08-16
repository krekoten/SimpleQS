$: << File.expand_path(File.join(File.dirname(__FILE__), '..'))
require 'rubygems'
require 'spec'
require 'lib/simple_qs'

unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_ACCOUNT_ID']
  abort "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ACCOUNT_ID environment variables"
end

SimpleQS.access_key_id			= ENV['AWS_ACCESS_KEY_ID']
SimpleQS.secret_access_key	= ENV['AWS_SECRET_ACCESS_KEY']
SimpleQS.account_id					= ENV['AWS_ACCOUNT_ID']
