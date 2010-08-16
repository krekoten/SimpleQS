require 'spec_helper'

module SimpleQS
	describe Message do
		before :all do
			@queue = SimpleQS::Queue.new('testQueue')
		end

		it 'should accept string as message' do
			string = 'Test message from SimpleQS::Message spec'
			message = SimpleQS::Message.new(@queue, string)
			message.body.should == string
		end

		it 'should return message instance when sent from class method' do
			string = 'Test message from SimpleQS::Message spec'

			message = SimpleQS::Message.send(@queue, string)

			message.should be_instance_of(SimpleQS::Message)
			message.body.should == string
			message.message_id.should_not be_empty
		end

		it 'should receive messages' do
			messages = SimpleQS::Message.receive(@queue)
			messages.should have_at_least(1).message
			messages[0].should be_instance_of(SimpleQS::Message)
		end

		it 'should receive at least 3 messages with attributes' do
			string = 'Test message from SimpleQS::Message spec'
			message = SimpleQS::Message.new(@queue, string)
			message.send
			message.resend
			message.resend
			message.resend

			messages = SimpleQS::Message.receive(@queue, :All, 3, 30)
			messages.should have_at_least(3).message
			messages[0].should be_instance_of(SimpleQS::Message)
		end

		describe 'when message is not sent' do
			before :each do
				@message = SimpleQS::Message.new(@queue, 'Test message from SimpleQS::Message spec')
			end

			it "should be sendable" do
				lambda do
					@message.send
				end.should_not raise_error
			end
		end

		describe 'when message is sent' do
			before :each do
				@message = SimpleQS::Message.new(@queue, 'Test message from SimpleQS::Message spec')
				@message.send
			end

			it "should not be sendable" do
				lambda do
					@message.send
				end.should raise_error(SimpleQS::Message::DoubleSendError)
			end

			it 'should be able to be resend' do
				lambda do
					@message.resend
				end.should_not raise_error
			end
			
			describe 'and then is resent' do
				it 'should not be equal to orginal message' do
					new_message = @message.resend
					new_message.should_not == @message
				end
			end
		end

		describe 'when receive messages' do
			before :each do
				@queue.send_message('Message 1')
				@queue.send_message('Message 2')
				@queue.send_message('Message 3')
				@messages = SimpleQS::Message.receive(@queue, nil, 10)
			end

			it 'should be able to delete message' do
				lambda do
					@messages.each do |message|
						message.delete
					end
				end.should_not raise_error
			end
		end

		describe 'change visibility of message' do
			it 'should be able when message is received' do
				lambda do
					@queue.send_message('Message')
					SimpleQS::Message.receive(@queue).last.change_visibility(120)
				end.should_not raise_error
			end

			it 'should not be able when message is not received' do
				lambda do
					SimpleQS::Message.new(@queue, 'Message').change_visibility(120)
				end.should raise_error(SimpleQS::Message::NotReceivedError)
			end
		end
	end
end
