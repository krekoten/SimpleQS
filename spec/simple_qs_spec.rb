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
  
  it 'should have default host' do
    SimpleQS.host.should == 'sqs.us-east-1.amazonaws.com'
  end
  
  it 'should return valid us-west-1 host' do
    SimpleQS.host = :us_west_1
    SimpleQS.host.should == 'sqs.us-west-1.amazonaws.com'
  end
  
  it 'should return valid eu-west-1 host' do
    SimpleQS.host = :eu_west_1
    SimpleQS.host.should == 'sqs.eu-west-1.amazonaws.com'
  end
  
  it 'should return valid ap-southeast-1 host' do
    SimpleQS.host = :ap_southeast_1
    SimpleQS.host.should == 'sqs.ap-southeast-1.amazonaws.com'
  end
end
