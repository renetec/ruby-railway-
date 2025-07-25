#\!/usr/bin/env ruby
require_relative 'config/environment'

puts '🔧 Testing messaging system in Docker...'

# Load test factories
load 'messaging_test_factories.rb'

puts '📋 Creating test data...'
alice = User.create\!(email: 'alice@test.com', name: 'Alice', password: 'password123')
bob = User.create\!(email: 'bob@test.com', name: 'Bob', password: 'password123')

conversation = Conversation.create\!(created_by: alice, conversation_type: 'direct_message')
UserConversation.create\!(user: alice, conversation: conversation)
UserConversation.create\!(user: bob, conversation: conversation)

message = Message.create\!(
  conversation: conversation,
  user: alice,
  content: 'Hello from Docker test\!',
  message_type: 'text'
)

puts "✅ Created users: #{User.count}"
puts "✅ Created conversations: #{Conversation.count}"
puts "✅ Created messages: #{Message.count}"
puts "✅ Message content: #{message.content}"
puts "✅ Message belongs to: #{message.user.name}"

# Test reply functionality
reply = Message.create\!(
  conversation: conversation,
  user: bob,
  content: 'Reply from Bob\!',
  message_type: 'text',
  reply_to_message_id: message.id
)

puts "✅ Reply created: #{reply.content}"
puts "✅ Reply references: #{reply.reply_to_message&.content}"

puts '🎉 Messaging system validation PASSED\!'
puts '🐳 Docker environment is working correctly\!'
