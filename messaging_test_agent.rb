# Messaging Test Agent - Automated Testing for Messaging System
# This class provides automated testing scenarios for the messaging system

require 'rails_helper'
require_relative 'messaging_test_factories'

class MessagingTestAgent
  attr_reader :results, :errors, :performance_metrics

  def initialize
    @results = []
    @errors = []
    @performance_metrics = {}
    @test_users = {}
  end

  # Main test runner
  def run_all_tests
    puts "🚀 Starting Messaging System Test Agent..."
    
    setup_test_environment
    
    run_basic_messaging_tests
    run_reply_functionality_tests
    run_delete_functionality_tests
    run_notification_tests
    run_real_time_tests
    run_performance_tests
    run_concurrent_user_tests
    run_error_handling_tests
    
    cleanup_test_environment
    
    generate_report
  end

  # Basic messaging functionality tests
  def run_basic_messaging_tests
    test_section("Basic Messaging Functionality") do
      # Test message creation
      conversation = create_test_conversation
      alice = @test_users[:alice]
      bob = @test_users[:bob]
      
      # Alice sends message
      message = test_send_message(alice, conversation, "Hello Bob!")
      assert message.persisted?, "Message should be saved to database"
      assert_equal "Hello Bob!", message.content
      assert_equal alice, message.user
      
      # Bob receives message
      messages = conversation.messages.where(user: alice)
      assert_equal 1, messages.count, "Bob should see Alice's message"
      
      record_test_result("Basic message sending", true)
    end
  end

  # Reply functionality tests
  def run_reply_functionality_tests
    test_section("Reply Functionality") do
      conversation = create_test_conversation
      alice = @test_users[:alice]
      bob = @test_users[:bob]
      
      # Alice sends original message
      original = test_send_message(alice, conversation, "What's the weather?")
      
      # Bob replies
      reply = test_send_reply(bob, conversation, "It's sunny!", original)
      assert reply.reply_to == original, "Reply should reference original message"
      assert original.replies.include?(reply), "Original should have reply"
      
      record_test_result("Message reply functionality", true)
    end
  end

  # Delete functionality tests
  def run_delete_functionality_tests
    test_section("Delete Functionality") do
      conversation = create_test_conversation
      alice = @test_users[:alice]
      
      # Alice sends message
      message = test_send_message(alice, conversation, "Delete this message")
      message_id = message.id
      
      # Alice deletes message
      message.destroy
      
      # Verify deletion
      assert_raises(ActiveRecord::RecordNotFound) { Message.find(message_id) }
      
      record_test_result("Message deletion", true)
    end
  end

  # Notification tests
  def run_notification_tests
    test_section("Notification System") do
      conversation = create_test_conversation
      alice = @test_users[:alice]
      bob = @test_users[:bob]
      
      # Test unread count calculation
      initial_unread = conversation.unread_count_for(bob)
      
      # Alice sends message
      test_send_message(alice, conversation, "Notification test")
      
      # Bob should have increased unread count
      updated_unread = conversation.unread_count_for(bob)
      assert updated_unread > initial_unread, "Unread count should increase"
      
      record_test_result("Notification unread count", true)
    end
  end

  # Real-time features tests
  def run_real_time_tests
    test_section("Real-time Features") do
      conversation = create_test_conversation
      alice = @test_users[:alice]
      
      # Test message broadcasting
      expect_broadcast = true
      
      # Simulate ActionCable broadcast test
      allow(ConversationChannel).to receive(:broadcast_to)
      
      message = test_send_message(alice, conversation, "Real-time test")
      
      # Verify broadcast was called
      expect(ConversationChannel).to have_received(:broadcast_to)
      
      record_test_result("Real-time broadcasting", true)
    end
  end

  # Performance tests
  def run_performance_tests
    test_section("Performance Testing") do
      conversation = create_test_conversation
      alice = @test_users[:alice]
      
      # Test message creation performance
      start_time = Time.current
      
      100.times do |i|
        test_send_message(alice, conversation, "Performance test message #{i}")
      end
      
      end_time = Time.current
      duration = end_time - start_time
      
      @performance_metrics[:message_creation_100] = duration
      
      # Test should complete in reasonable time (under 5 seconds)
      assert duration < 5.0, "Creating 100 messages should take less than 5 seconds"
      
      record_test_result("Performance - 100 messages", true, { duration: duration })
    end
  end

  # Concurrent user tests
  def run_concurrent_user_tests
    test_section("Concurrent Users") do
      conversation = create_test_conversation
      users = [@test_users[:alice], @test_users[:bob], @test_users[:charlie]]
      
      # Simulate concurrent message sending
      threads = []
      
      users.each_with_index do |user, index|
        threads << Thread.new do
          5.times do |i|
            test_send_message(user, conversation, "Concurrent message from #{user.name} - #{i}")
            sleep(0.1) # Small delay to simulate realistic timing
          end
        end
      end
      
      # Wait for all threads to complete
      threads.each(&:join)
      
      # Verify all messages were created
      total_messages = conversation.messages.count
      expected_messages = users.count * 5
      
      assert_equal expected_messages, total_messages, "All concurrent messages should be saved"
      
      record_test_result("Concurrent user messaging", true, { users: users.count, messages: total_messages })
    end
  end

  # Error handling tests
  def run_error_handling_tests
    test_section("Error Handling") do
      conversation = create_test_conversation
      alice = @test_users[:alice]
      
      # Test invalid message creation
      begin
        invalid_message = Message.create!(
          conversation: conversation,
          user: alice,
          content: nil, # Invalid - no content and no attachments
        )
        record_test_result("Invalid message handling", false, { error: "Should have failed validation" })
      rescue ActiveRecord::RecordInvalid
        record_test_result("Invalid message handling", true, { error: "Correctly rejected invalid message" })
      end
      
      # Test broadcast error handling
      allow(ConversationChannel).to receive(:broadcast_to).and_raise(StandardError.new("Broadcast failed"))
      allow(Rails.logger).to receive(:error)
      
      # Should not raise error even if broadcast fails
      begin
        test_send_message(alice, conversation, "Error handling test")
        record_test_result("Broadcast error handling", true)
      rescue StandardError => e
        record_test_result("Broadcast error handling", false, { error: e.message })
      end
    end
  end

  # Test utilities
  private

  def setup_test_environment
    puts "🔧 Setting up test environment..."
    
    # Create test users
    @test_users[:alice] = FactoryBot.create(:alice)
    @test_users[:bob] = FactoryBot.create(:bob)
    @test_users[:charlie] = FactoryBot.create(:charlie)
    
    puts "✅ Test environment ready"
  end

  def cleanup_test_environment
    puts "🧹 Cleaning up test environment..."
    
    # Clean up test data
    Message.where(user: @test_users.values).delete_all
    Conversation.where(created_by: @test_users.values).delete_all
    @test_users.values.each(&:destroy)
    
    puts "✅ Cleanup completed"
  end

  def create_test_conversation
    conversation = FactoryBot.create(:test_conversation, created_by: @test_users[:alice])
    
    # Add all test users to conversation
    @test_users.each do |name, user|
      FactoryBot.create(:test_user_conversation, user: user, conversation: conversation)
    end
    
    conversation
  end

  def test_send_message(user, conversation, content)
    Message.create!(
      user: user,
      conversation: conversation,
      content: content,
      message_type: :text,
      delivery_status: :sent
    )
  end

  def test_send_reply(user, conversation, content, reply_to)
    Message.create!(
      user: user,
      conversation: conversation,
      content: content,
      reply_to: reply_to,
      message_type: :text,
      delivery_status: :sent
    )
  end

  def test_section(name)
    puts "\n📋 Testing: #{name}"
    yield
  rescue StandardError => e
    record_error(name, e)
    puts "❌ #{name} failed: #{e.message}"
  end

  def record_test_result(test_name, success, metadata = {})
    @results << {
      test: test_name,
      success: success,
      timestamp: Time.current,
      metadata: metadata
    }
    
    status = success ? "✅" : "❌"
    puts "   #{status} #{test_name}"
  end

  def record_error(test_name, error)
    @errors << {
      test: test_name,
      error: error.message,
      backtrace: error.backtrace.first(5),
      timestamp: Time.current
    }
  end

  def assert(condition, message = "Assertion failed")
    raise StandardError.new(message) unless condition
  end

  def assert_equal(expected, actual, message = nil)
    message ||= "Expected #{expected}, got #{actual}"
    assert expected == actual, message
  end

  def assert_raises(exception_class)
    yield
    raise StandardError.new("Expected #{exception_class} to be raised")
  rescue exception_class
    # Expected exception was raised
    true
  end

  def generate_report
    puts "\n" + "="*60
    puts "📊 MESSAGING SYSTEM TEST REPORT"
    puts "="*60
    
    total_tests = @results.count
    passed_tests = @results.count { |r| r[:success] }
    failed_tests = total_tests - passed_tests
    
    puts "Total Tests: #{total_tests}"
    puts "Passed: #{passed_tests}"
    puts "Failed: #{failed_tests}"
    puts "Success Rate: #{((passed_tests.to_f / total_tests) * 100).round(2)}%" if total_tests > 0
    
    if @performance_metrics.any?
      puts "\n⚡ Performance Metrics:"
      @performance_metrics.each do |metric, value|
        puts "  #{metric}: #{value.round(3)}s"
      end
    end
    
    if @errors.any?
      puts "\n❌ Errors:"
      @errors.each do |error|
        puts "  #{error[:test]}: #{error[:error]}"
      end
    end
    
    puts "\n✅ Test completed at #{Time.current}"
    puts "="*60
    
    # Return summary
    {
      total: total_tests,
      passed: passed_tests,
      failed: failed_tests,
      success_rate: total_tests > 0 ? (passed_tests.to_f / total_tests) * 100 : 0,
      performance: @performance_metrics,
      errors: @errors
    }
  end
end

# Usage example and test runner
if __FILE__ == $0
  # Run the test agent
  agent = MessagingTestAgent.new
  results = agent.run_all_tests
  
  # Exit with error code if tests failed
  exit(1) if results[:failed] > 0
end