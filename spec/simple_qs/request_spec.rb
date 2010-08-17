require 'spec_helper'

module SimpleQS
  describe Request do
    before :each do
      @query_params = {
        'Action'            => 'SetQueueAttributes',
        'Attribute.Name'    => 'VisibilityTimeout',
        'Attribute.Value'   => 90,
        'Expires'           => '2008-02-10T12:00:00Z'
      }
      
      @get_request = SimpleQS::Request::Get.new(@query_params)
    end
    
    it 'should raise error if object passed to timestampt is not of Time kind' do
      lambda {
        @get_request.timestamp = '10-10-2010'
      }.should raise_error(ArgumentError)
    end
    
    it 'should build correct request' do
      SimpleQS::Request.build(:get, @query_params).should == @get_request
    end
    
    it 'should raise SimpleQS::Request::UnknownHttpMethod if unknown method passed' do
      lambda {
        SimpleQS::Request.build(:head, @query_params)
      }.should raise_error(SimpleQS::Request::UnknownHttpMethod)
    end
    
    it 'should generate correct canonicalized query string' do
      @get_request.canonical_query_string.should == "AWSAccessKeyId=#{SimpleQS.access_key_id}&Action=SetQueueAttributes&Attribute.Name=VisibilityTimeout&Attribute.Value=90&Expires=2008-02-10T12%3A00%3A00Z&SignatureMethod=HmacSHA1&SignatureVersion=2&Version=2009-02-01"
    end
    
    it 'should generate correct base string' do
      @get_request.query_string = '/770098461991/queue2'
      @get_request.signature_base_string.should == "GET\n#{SimpleQS.host}\n/770098461991/queue2\nAWSAccessKeyId=#{SimpleQS.access_key_id}&Action=SetQueueAttributes&Attribute.Name=VisibilityTimeout&Attribute.Value=90&Expires=2008-02-10T12%3A00%3A00Z&SignatureMethod=HmacSHA1&SignatureVersion=2&Version=2009-02-01"
      
      @get_request.query_string = '770098461991/queue2'
      @get_request.signature_base_string.should == "GET\n#{SimpleQS.host}\n/770098461991/queue2\nAWSAccessKeyId=#{SimpleQS.access_key_id}&Action=SetQueueAttributes&Attribute.Name=VisibilityTimeout&Attribute.Value=90&Expires=2008-02-10T12%3A00%3A00Z&SignatureMethod=HmacSHA1&SignatureVersion=2&Version=2009-02-01"
      
      @get_request.query_string = ['770098461991', 'queue2']
      @get_request.signature_base_string.should == "GET\n#{SimpleQS.host}\n/770098461991/queue2\nAWSAccessKeyId=#{SimpleQS.access_key_id}&Action=SetQueueAttributes&Attribute.Name=VisibilityTimeout&Attribute.Value=90&Expires=2008-02-10T12%3A00%3A00Z&SignatureMethod=HmacSHA1&SignatureVersion=2&Version=2009-02-01"
      
      @get_request.query_string = nil
      @get_request.signature_base_string.should == "GET\n#{SimpleQS.host}\n/\nAWSAccessKeyId=#{SimpleQS.access_key_id}&Action=SetQueueAttributes&Attribute.Name=VisibilityTimeout&Attribute.Value=90&Expires=2008-02-10T12%3A00%3A00Z&SignatureMethod=HmacSHA1&SignatureVersion=2&Version=2009-02-01"
    end
    
    it '#sign! should generate signature from base string' do
      @get_request.query_string = ['770098461991', 'queue2']
      @get_request.sign!
      @get_request.query_params['Signature'].should_not be_empty
    end
  end
end
