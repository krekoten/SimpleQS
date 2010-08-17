require 'spec_helper'

module SimpleQS
  describe Queue do
    describe 'create method' do
      it 'should raise error if queue name is longer than 80 characters' do
        lambda do
          SimpleQS::Queue.create('a' * 81)
        end.should raise_error(ArgumentError)
      end
      
      it 'should accept only alphanumeric characters, hyphens (-), and underscores (_)' do
        lambda do
          SimpleQS::Queue.check_queue_name('test&queue')
        end.should raise_error(ArgumentError)
        
        lambda do
          SimpleQS::Queue.check_queue_name('test_queue-123ABC')
        end.should_not raise_error(ArgumentError)
      end
      
      it 'should raise error if passed too long visibility timeout' do
        lambda do
          SimpleQS::Queue.check_visibility_timeout(SimpleQS::Queue::MAX_VISIBILITY_TIMEOUT + 1)
        end.should raise_error(SimpleQS::Queue::MaxVisibilityError)
      end
      
      it 'should raise error if passed negative visibility timeout' do
        lambda do
          SimpleQS::Queue.check_visibility_timeout(-1)
        end.should raise_error(SimpleQS::Queue::MaxVisibilityError)
      end
      
      it 'should raise error if visibility timeout is not fixnum' do
        lambda do
          SimpleQS::Queue.check_visibility_timeout(Object.new)
        end.should raise_error(ArgumentError)
      end
      
      it 'should return SimpleQS::Queue instance' do
        SimpleQS::Queue.create('testQueue').should be_instance_of(SimpleQS::Queue)
      end
      
      it 'should pass SimpleQS::Queue instance to block' do
        _queue = nil
        SimpleQS::Queue.create('testQueue') do |queue|
          _queue = queue
        end
        
        _queue.should be_instance_of(SimpleQS::Queue)
      end
    end
    
    it 'should have at least 1 queue' do
      SimpleQS::Queue.list.should have_at_least(1).queue
    end

    it 'should find at least 1 queue by beggining of the name' do
      SimpleQS::Queue.list('test').should have_at_least(1).queue
    end

    it 'should find 0 queues with nonexistent names' do
      SimpleQS::Queue.list('nonExistantQueueName').should have(0).queue
    end

    it 'should be able to get all queue attributes' do
      SimpleQS::Queue.new('testQueue').get_attributes(:All).should_not be_empty
    end

    it 'should be able to change default visibility timeout for queue' do
      lambda do
        SimpleQS::Queue.new('testQueue').set_visibility_timeout(60)
      end.should_not raise_error
    end

    it 'should be able to set default visibility timeout for queue using set_attributes' do
      lambda do
        SimpleQS::Queue.new('testQueue').set_attributes({:VisibilityTimeout => 30})
      end.should_not raise_error
    end

    it 'should be able to add permissions' do
      lambda do
        SimpleQS::Queue.new('testQueue').add_permissions('testPerms', [
          {:account_id => '098166147350', :action => 'SendMessage'},
          {:account_id => '098166147350', :action => 'ReceiveMessage'}
        ])
      end.should_not raise_error
    end

    it 'should be able to remove permissions' do
      lambda do
        SimpleQS::Queue.new('testQueue').remove_permissions('testPerms')
      end.should_not raise_error
    end
    
    it 'should respond true if queue exists' do
      SimpleQS::Queue.exists?('testQueue').should == true
    end
    
    it 'should respond false if queue does not exist' do
      SimpleQS::Queue.exists?('nonExistantQueue123').should == false
    end

    it 'should be able to delete queue' do
      lambda do
        queue_name = Time.now.to_i.to_s
        SimpleQS::Queue.create(queue_name)
        SimpleQS::Queue.delete(queue_name)
      end.should_not raise_error
    end
  end
end
