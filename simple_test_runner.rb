#!/usr/bin/env ruby
# Simple Test Runner for Docker environment without external dependencies

class SimpleTestRunner
  def initialize
    @start_time = Time.now
  end

  def run
    puts "🧪 Messaging System Test Suite"
    puts "=" * 50
    
    # Load Rails environment
    load_rails_environment
    
    # Run tests
    results = {}
    results[:unit] = run_unit_tests
    results[:system] = run_system_tests
    results[:notifications] = run_notification_tests
    results[:agent] = run_agent_tests
    
    # Generate summary
    generate_summary(results)
    
    # Exit with appropriate code
    failed_tests = results.values.count { |result| result && !result[:success] }
    exit(failed_tests > 0 ? 1 : 0)
  end

  private

  def load_rails_environment
    puts "🔧 Loading Rails environment..."
    
    begin
      require File.expand_path('../config/environment', __FILE__)
      puts "✅ Rails environment loaded"
    rescue LoadError => e
      puts "❌ Failed to load Rails environment: #{e.message}"
      puts "   Make sure you're running from the Rails app root directory"
      exit(1)
    end
  end

  def run_unit_tests
    puts "\n📋 Running Unit Tests"
    puts "-" * 30
    
    start_time = Time.now
    success = system("bundle exec rspec enhanced_message_spec.rb")
    duration = Time.now - start_time
    
    result = {
      name: "Unit Tests",
      success: success,
      duration: duration
    }
    
    puts "#{result[:name]}: #{success ? 'PASSED' : 'FAILED'} (#{duration.round(2)}s)"
    result
  end

  def run_system_tests
    puts "\n🖥️  Running System Tests"
    puts "-" * 30
    
    start_time = Time.now
    success = system("bundle exec rspec messaging_system_spec.rb")
    duration = Time.now - start_time
    
    result = {
      name: "System Tests",
      success: success,
      duration: duration
    }
    
    puts "#{result[:name]}: #{success ? 'PASSED' : 'FAILED'} (#{duration.round(2)}s)"
    result
  end

  def run_notification_tests
    puts "\n🔔 Running Notification Tests"
    puts "-" * 30
    
    start_time = Time.now
    success = system("bundle exec rspec notification_system_spec.rb")
    duration = Time.now - start_time
    
    result = {
      name: "Notification Tests",
      success: success,
      duration: duration
    }
    
    puts "#{result[:name]}: #{success ? 'PASSED' : 'FAILED'} (#{duration.round(2)}s)"
    result
  end

  def run_agent_tests
    puts "\n🤖 Running Test Agent"
    puts "-" * 30
    
    start_time = Time.now
    
    begin
      require_relative 'messaging_test_agent'
      agent = MessagingTestAgent.new
      agent_results = agent.run_all_tests
      
      duration = Time.now - start_time
      success = agent_results[:failed] == 0
      
      result = {
        name: "Test Agent",
        success: success,
        duration: duration,
        details: agent_results
      }
      
      puts "#{result[:name]}: #{success ? 'PASSED' : 'FAILED'} (#{duration.round(2)}s)"
      puts "  Tests: #{agent_results[:passed]}/#{agent_results[:total]} passed"
      result
      
    rescue => e
      puts "❌ Test Agent failed: #{e.message}"
      duration = Time.now - start_time
      
      {
        name: "Test Agent",
        success: false,
        duration: duration,
        error: e.message
      }
    end
  end

  def generate_summary(results)
    puts "\n" + "=" * 60
    puts "📊 TEST SUMMARY REPORT"
    puts "=" * 60
    
    total_duration = Time.now - @start_time
    passed_count = results.values.count { |result| result && result[:success] }
    total_count = results.values.count { |result| result }
    
    results.each do |suite, result|
      next unless result
      status = result[:success] ? "✅ PASSED" : "❌ FAILED"
      puts "#{result[:name]}: #{status} (#{result[:duration].round(2)}s)"
    end
    
    puts "\n" + "-" * 60
    puts "SUMMARY:"
    puts "  Test Suites: #{passed_count}/#{total_count} passed"
    puts "  Total Duration: #{total_duration.round(2)}s"
    
    if passed_count == total_count
      puts "\n✅ All tests passed!"
    else
      puts "\n❌ Some tests failed"
    end
    
    puts "=" * 60
    puts "Test completed at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end
end

# Run the test suite
if __FILE__ == $0
  runner = SimpleTestRunner.new
  runner.run
end