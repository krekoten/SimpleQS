require 'spec_helper'
describe SimpleQS do
  it 'should be able to set and retrieve access key id' do
    SimpleQS.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    SimpleQS.access_key_id.should == ENV['AWS_ACCESS_KEY_ID']
  end
  
  it 'should be able to set and retrieve secret access key' do
    SimpleQS.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    SimpleQS.secret_access_key.should == ENV['AWS_SECRET_ACCESS_KEY']
  end
  
  it 'should be able to set and retrieve account id' do
    SimpleQS.account_id = ENV['AWS_ACCOUNT_ID']
    SimpleQS.account_id.should == ENV['AWS_ACCOUNT_ID'].gsub(/[^0-9]/, '')
  end
end
