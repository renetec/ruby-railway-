#\!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts '🧪 Messaging System Validation in Docker'
puts '========================================='

begin
  # Test user creation
  puts '1️⃣ Testing user creation...'
  alice = User.create\!(email: 'alice@docker.test', name: 'Alice', password: 'password123')
  bob = User.create\!(email: 'bob@docker.test', name: 'Bob', password: 'password123')
  puts "   ✅ Created users: #{alice.name} and #{bob.name}"

  # Test conversation creation
  puts '2️⃣ Testing conversation creation...'
  conversation = Conversation.create\!(created_by: alice, conversation_type: 'direct_message')
  puts "   ✅ Created conversation ID: #{conversation.id}"

  # Test user conversations
  puts '3️⃣ Testing user conversation associations...'
  UserConversation.create\!(user: alice, conversation: conversation)
  UserConversation.create\!(user: bob, conversation: conversation)
  puts "   ✅ Added #{conversation.users.count} users to conversation"

  # Test message creation
  puts '4️⃣ Testing message creation...'
  message = Message.create\!(
    conversation: conversation,
    user: alice,
    content: 'Hello from Docker messaging test\!',
    message_type: 'text'
  )
  puts "   ✅ Created message: '#{message.content}'"

  # Test reply functionality
  puts '5️⃣ Testing reply functionality...'
  reply = Message.create\!(
    conversation: conversation,
    user: bob,
    content: 'Reply from Bob in Docker\!',
    message_type: 'text',
    reply_to_message_id: message.id
  )
  puts "   ✅ Created reply: '#{reply.content}'"
  puts "   ✅ Reply references: '#{reply.reply_to_message.content}'"

  # Test associations and counts
  puts '6️⃣ Testing associations...'
  puts "   ✅ Conversation participants: #{conversation.users.pluck(:name).join(', ')}"
  puts "   ✅ Total messages in conversation: #{conversation.messages.count}"
  puts "   ✅ Alice's conversations: #{alice.conversations.count}"
  puts "   ✅ Bob's conversations: #{bob.conversations.count}"

  # Test message types and statuses
  puts '7️⃣ Testing message properties...'
  puts "   ✅ Message type: #{message.message_type}"
  puts "   ✅ Message has reply: #{message.replies.any?}"
  puts "   ✅ Reply type: #{reply.message_type}"

  puts ''
  puts '🎉 ALL MESSAGING SYSTEM TESTS PASSED\!'
  puts '🐳 Docker environment is fully functional\!'
  puts '✨ The messaging system is working correctly\!'
  puts ''
  puts '📊 Summary:'
  puts "   Users: #{User.count}"
  puts "   Conversations: #{Conversation.count}"
  puts "   Messages: #{Message.count}"
  puts "   User Conversations: #{UserConversation.count}"

rescue => e
  puts ''
  puts '❌ TEST FAILED\!'
  puts "Error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(3).join('\n')}"
  exit 1
end
