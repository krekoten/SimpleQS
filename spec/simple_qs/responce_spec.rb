require 'spec_helper'

module ResponceHelper
	def successful_responce
		responce_xml = %{
			<CreateQueueResponse
				xmlns="http://queue.amazonaws.com/doc/2009-02-01/"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xsi:type="CreateQueueResponse">
				
				<CreateQueueResult>
					<QueueUrl>http://queue.amazonaws.com/770098461991/queue2</QueueUrl>
				</CreateQueueResult>
				<ResponseMetadata>
					<RequestId>cb919c0a-9bce-4afe-9b48-9bdf2412bb67</RequestId>
				</ResponseMetadata>
				
			</CreateQueueResponse>
		}
		
		SimpleQS::Responce.new responce_xml
	end

	def failure_responce
		responce_xml = %{
			<ErrorResponse>
				<Error>
					<Type>Sender</Type>
					<Code>InvalidParameterValue</Code>
					<Message>Value (quename_nonalpha) for parameter QueueName is invalid. Must be an alphanumeric String of 1 to 80 in length</Message>
				</Error>
				<RequestId>42d59b56-7407-4c4a-be0f-4c88daeea257</RequestId>
			</ErrorResponse>
		}
		
		SimpleQS::Responce.new responce_xml
	end
end

module SimpleQS
  describe Responce do
    describe 'when request is successful' do

			include ResponceHelper

      before :each do
				@responce = successful_responce
      end
      
      it 'should be successful' do
        @responce.should be_successful
      end
      
      it 'should have request id' do
        @responce.request_id.should == 'cb919c0a-9bce-4afe-9b48-9bdf2412bb67'
      end
      
      it 'should have action name' do
        @responce.action_name.should == 'CreateQueue'
      end
      
      it 'should have action specific responce values' do
        @responce.queue_url.should == 'http://queue.amazonaws.com/770098461991/queue2'
      end
    end
    
    describe 'when request is unsuccessful' do

			include ResponceHelper

      before :each do
				@responce = failure_responce
      end
      
      it 'should not be successful' do
        @responce.should_not be_successful
      end
      
      it 'should be sender error' do
        @responce.should be_sender_error
      end
      
      it 'should have request id' do
        @responce.request_id.should == '42d59b56-7407-4c4a-be0f-4c88daeea257'
      end
      
      it 'should not be receiver error' do
        @responce.should_not be_receiver_error
      end
      
      it 'should have error code' do
        @responce.error_code.should == 'InvalidParameterValue'
      end
      
      it 'should have error message' do
        @responce.error_message.should == "Value (quename_nonalpha) for parameter QueueName is invalid. Must be an alphanumeric String of 1 to 80 in length"
      end
      
      describe 'when error is returned' do
        it 'should be valid error instance' do
          @responce.to_error.should be_instance_of(SimpleQS::Responce::InvalidParameterValueError)
        end
      
        it 'should contain valid message' do
          @responce.to_error.message.should == @responce.error_message
        end
      end
    end

		include ResponceHelper

		it 'should define singleton methods for each instance' do
			success = successful_responce
			failure = failure_responce
			success.request_id.should_not == failure.request_id
		end
  end
end
