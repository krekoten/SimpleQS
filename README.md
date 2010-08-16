# English #
## Installation ##
		[sudo] gem install simple_qs
## Usage ##
		require 'simple_qs'
		SimpleQS.account_id = 'your-account-id'
		SimpleQS.access_key_id = 'YOUR_ACCESS_KEY'
		SimpleQS.secret_access_key = 'YOUR_SECRET_ACCESS_KEY'
### Queues ###
Create a queue:
		queue = SimpleQS::Queue.create('queue_name')
Or:
		SimpleQS::Queue.create('queue_name') do |queue|
			# ...
		end
Create a queue with specific default visibility timeout for received messages:
		SimpleQS::Queue.create('queue_name', 60) # Visibility timeout set to 60 secinds instead of default 30
List all account's queues:
		SimpleQS::Queue.list # returns list of SimpleQS::Queue objects
List all account's queues starting with 'test':
		SimpleQS::Queue.list('test')
Change default visibility timeout for queue:
		SimpleQS::Queue.new('queue_name').set_visibility_timeout(120)
Set queue attributes:
		SimpleQS::Queue.new('queue_name').set_attributes({:VisibilityTimeout => 120, :Policy => "policy JSON here"})
Get queue attributes:
		SimpleQS::Queue.new('queue_name').get_attributes(:All)
Add permissions:
		SimpleQS::Queue.new('queue_name').add_permissions('testPerms', [
			{:account_id => '098166147350', :action => 'SendMessage'},
			{:account_id => '098166147350', :action => 'ReceiveMessage'}
		])
Remove permissions:
		SimpleQS::Queue.new('queue_name').remove_permissions('testPerms')
Delete queue:
		SimpleQS::Queue.new('queue_name').delete
### Messages ###
Send message:
		queue = SimpleQS::Queue.new('queue_name')
		queue.send_message('message 1')
		queue.send_message('message 2')
Or:
		SimpleQS::Message.send(queue, 'message 1')
		SimpleQS::Message.send(queue, 'message 2')
Receive message(s):
		queue.receive_messages # always returns array of messages
		queue.receive_messages(:All, 10, 70) # receive maximum 10 messages with all attributes (:All)
											 # and set for them visibility timeout to 70 seconds
Or:
		SimpleQS::Message.receive(queue)
		SimpleQS::Message.receive(queue, :All, 10, 70)
Resend received message:
		messages = queue.receive_messages
		messages.first.resend
Change visibility timeout for this message:
		messages.first.change_visibility(120) # Change to 120 seconds
Delete received message:
		messages.first.delete
## TODO ##
See [TODO](http://github.com/krekoten/SimpleQS/blob/master/TODO.md) file
## Issues ##
[ISSUES](http://github.com/krekoten/SimpleQS/issues)
## Authors ##
Marjan Krekoten' (krekoten@gmail.com)
# Українською #
## Встановлення ##
		[sudo] gem install simple_qs
## Користування ##
		require 'simple_qs'
		SimpleQS.account_id = 'your-account-id'
		SimpleQS.access_key_id = 'YOUR_ACCESS_KEY'
		SimpleQS.secret_access_key = 'YOUR_SECRET_ACCESS_KEY'
### Черги ###
Створити чергу:
		queue = SimpleQS::Queue.create('queue_name')
Або:
		SimpleQS::Queue.create('queue_name') do |queue|
			# ...
		end
Створити чергу із специфічним обмеженням часу невидимості для отриманих повідомлень:
		SimpleQS::Queue.create('queue_name', 60) # Час невидимості встановленно на 60 секунд, натомість типових 30-ти
Перелислити всі черги данного рахунку:
		SimpleQS::Queue.list # returns list of SimpleQS::Queue objects
Перечислити всі черги даного рахунку, що починаються на 'test':
		SimpleQS::Queue.list('test')
Змінити типовий час невидимості для даної черги:
		SimpleQS::Queue.new('queue_name').set_visibility_timeout(120)
Встановити атрибути черги:
		SimpleQS::Queue.new('queue_name').set_attributes({:VisibilityTimeout => 120, :Policy => "policy JSON here"})
Отримати поточні атрибути черги:
		SimpleQS::Queue.new('queue_name').get_attributes(:All)
Надати дозволи:
		SimpleQS::Queue.new('queue_name').add_permissions('testPerms', [
			{:account_id => '098166147350', :action => 'SendMessage'},
			{:account_id => '098166147350', :action => 'ReceiveMessage'}
		])
Скасувати дозволи:
		SimpleQS::Queue.new('queue_name').remove_permissions('testPerms')
Видалити чергу:
		SimpleQS::Queue.new('queue_name').delete
### Повідомлення ###
Відправити повідомлення:
		queue = SimpleQS::Queue.new('queue_name')
		queue.send_message('message 1')
		queue.send_message('message 2')
Або:
		SimpleQS::Message.send(queue, 'message 1')
		SimpleQS::Message.send(queue, 'message 2')
Отримати повідомлення:
		queue.receive_messages # завжди повертає масив
		queue.receive_messages(:All, 10, 70) # отримати максимум 10 повідомлень зі всіма атрибутами (:All)
											 # та встановленим часом невидимості у 70 секунд
Або:
		SimpleQS::Message.receive(queue)
		SimpleQS::Message.receive(queue, :All, 10, 70)
Надіслати отримані повідомлення ще раз:
		messages = queue.receive_messages
		messages.first.resend
Змінити час невидимості для даного повідомлення:
		messages.first.change_visibility(120) # Встановити у 120 секунд
Видалити отримане повідомлення з черги:
		messages.first.delete
## Що потрібно зробити ##
Дивіться [TODO](http://github.com/krekoten/SimpleQS/blob/master/TODO.md)
## Помилки, побажання і т.і. ##
[ISSUES](http://github.com/krekoten/SimpleQS/issues)
## Автори ##
Мар'ян Крекотень (krekoten@gmail.com)
