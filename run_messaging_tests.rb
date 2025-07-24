#!/usr/bin/env ruby
# Messaging Test Runner - Comprehensive testing for the messaging system

require 'optparse'
require 'colorize'

class MessagingTestRunner
  def initialize
    @options = {
      unit: true,
      system: true,
      agent: true,
      notifications: true,
      verbose: false,
      parallel: false
    }
    
    parse_options
  end

  def run
    puts "🧪 Messaging System Test Suite".colorize(:blue).bold
    puts "=" * 50
    
    start_time = Time.current
    results = {}
    
    # Load Rails environment
    load_rails_environment
    
    # Run selected test suites
    results[:unit] = run_unit_tests if @options[:unit]
    results[:system] = run_system_tests if @options[:system]
    results[:notifications] = run_notification_tests if @options[:notifications]
    results[:agent] = run_agent_tests if @options[:agent]
    
    end_time = Time.current
    total_duration = end_time - start_time
    
    # Generate summary report
    generate_summary_report(results, total_duration)
    
    # Exit with appropriate code
    exit_code = results.values.any? { |result| result && result[:failures] > 0 } ? 1 : 0
    exit(exit_code)
  end

  private

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby run_messaging_tests.rb [options]"
      
      opts.on("--unit-only", "Run only unit tests") do
        @options[:system] = false
        @options[:agent] = false
        @options[:notifications] = false
      end
      
      opts.on("--system-only", "Run only system tests") do
        @options[:unit] = false
        @options[:agent] = false
        @options[:notifications] = false
      end
      
      opts.on("--agent-only", "Run only test agent") do
        @options[:unit] = false
        @options[:system] = false
        @options[:notifications] = false
      end
      
      opts.on("--notifications-only", "Run only notification tests") do
        @options[:unit] = false
        @options[:system] = false
        @options[:agent] = false
      end
      
      opts.on("--no-unit", "Skip unit tests") do
        @options[:unit] = false
      end
      
      opts.on("--no-system", "Skip system tests") do
        @options[:system] = false
      end
      
      opts.on("--no-agent", "Skip test agent") do
        @options[:agent] = false
      end
      
      opts.on("--no-notifications", "Skip notification tests") do
        @options[:notifications] = false
      end
      
      opts.on("-v", "--verbose", "Verbose output") do
        @options[:verbose] = true
      end
      
      opts.on("-p", "--parallel", "Run tests in parallel") do
        @options[:parallel] = true
      end
      
      opts.on("-h", "--help", "Show this help") do
        puts opts
        exit
      end
    end.parse!
  end

  def load_rails_environment
    puts "🔧 Loading Rails environment...".colorize(:yellow)
    
    begin
      require File.expand_path('../config/environment', __FILE__)
      puts "✅ Rails environment loaded".colorize(:green)
    rescue LoadError => e
      puts "❌ Failed to load Rails environment: #{e.message}".colorize(:red)
      puts "   Make sure you're running from the Rails app root directory"
      exit(1)
    end
  end

  def run_unit_tests
    puts "\n📋 Running Unit Tests".colorize(:blue).bold
    puts "-" * 30
    
    start_time = Time.current
    
    # Run RSpec for unit tests
    cmd = build_rspec_command([
      'enhanced_message_spec.rb'
    ])
    
    success = system(cmd)
    duration = Time.current - start_time
    
    result = parse_rspec_output(success, duration, "Unit Tests")
    puts result[:summary].colorize(result[:color])
    
    result
  end

  def run_system_tests
    puts "\n🖥️  Running System Tests".colorize(:blue).bold
    puts "-" * 30
    
    start_time = Time.current
    
    # Run system tests
    cmd = build_rspec_command([
      'messaging_system_spec.rb'
    ])
    
    success = system(cmd)
    duration = Time.current - start_time
    
    result = parse_rspec_output(success, duration, "System Tests")
    puts result[:summary].colorize(result[:color])
    
    result
  end

  def run_notification_tests
    puts "\n🔔 Running Notification Tests".colorize(:blue).bold
    puts "-" * 30
    
    start_time = Time.current
    
    # Run notification tests
    cmd = build_rspec_command([
      'notification_system_spec.rb'
    ])
    
    success = system(cmd)
    duration = Time.current - start_time
    
    result = parse_rspec_output(success, duration, "Notification Tests")
    puts result[:summary].colorize(result[:color])
    
    result
  end

  def run_agent_tests
    puts "\n🤖 Running Test Agent".colorize(:blue).bold
    puts "-" * 30
    
    start_time = Time.current
    
    begin
      # Load and run the test agent
      require_relative 'messaging_test_agent'
      agent = MessagingTestAgent.new
      agent_results = agent.run_all_tests
      
      duration = Time.current - start_time
      
      result = {
        name: "Test Agent",
        duration: duration,
        examples: agent_results[:total],
        failures: agent_results[:failed],
        pending: 0,
        success: agent_results[:failed] == 0,
        color: agent_results[:failed] == 0 ? :green : :red,
        summary: "Agent: #{agent_results[:passed]}/#{agent_results[:total]} passed (#{agent_results[:success_rate].round(1)}%)"
      }
      
      puts result[:summary].colorize(result[:color])
      result
      
    rescue => e
      puts "❌ Test Agent failed: #{e.message}".colorize(:red)
      puts e.backtrace.first(5).join("\n") if @options[:verbose]
      
      {
        name: "Test Agent",
        duration: Time.current - start_time,
        examples: 0,
        failures: 1,
        pending: 0,
        success: false,
        color: :red,
        summary: "Agent: Failed with error"
      }
    end
  end

  def build_rspec_command(files)
    cmd = "bundle exec rspec"
    cmd += " --format progress"
    cmd += " --format json --out rspec_results.json"
    cmd += " --verbose" if @options[:verbose]
    cmd += " " + files.join(" ")
    cmd
  end

  def parse_rspec_output(success, duration, test_name)
    # Try to parse JSON output if available
    if File.exist?('rspec_results.json')
      begin
        results = JSON.parse(File.read('rspec_results.json'))
        File.delete('rspec_results.json')
        
        return {
          name: test_name,
          duration: duration,
          examples: results['summary']['example_count'],
          failures: results['summary']['failure_count'],
          pending: results['summary']['pending_count'],
          success: results['summary']['failure_count'] == 0,
          color: results['summary']['failure_count'] == 0 ? :green : :red,
          summary: "#{test_name}: #{results['summary']['example_count'] - results['summary']['failure_count']}/#{results['summary']['example_count']} passed"
        }
      rescue JSON::ParserError
        # Fall back to basic parsing
      end
    end
    
    # Basic result based on exit code
    {
      name: test_name,
      duration: duration,
      examples: success ? 1 : 0,
      failures: success ? 0 : 1,
      pending: 0,
      success: success,
      color: success ? :green : :red,
      summary: "#{test_name}: #{success ? 'PASSED' : 'FAILED'}"
    }
  end

  def generate_summary_report(results, total_duration)
    puts "\n" + "=" * 60
    puts "📊 TEST SUMMARY REPORT".colorize(:blue).bold
    puts "=" * 60
    
    total_examples = 0
    total_failures = 0
    total_pending = 0
    
    results.each do |suite, result|
      next unless result
      
      puts "#{result[:name]}:".ljust(20) + result[:summary].colorize(result[:color])
      puts "  Duration: #{result[:duration].round(2)}s"
      
      total_examples += result[:examples]
      total_failures += result[:failures]
      total_pending += result[:pending]
    end
    
    puts "\n" + "-" * 60
    puts "TOTALS:"
    puts "  Examples: #{total_examples}"
    puts "  Failures: #{total_failures}".colorize(total_failures > 0 ? :red : :green)
    puts "  Pending: #{total_pending}".colorize(total_pending > 0 ? :yellow : :green)
    puts "  Duration: #{total_duration.round(2)}s"
    
    success_rate = total_examples > 0 ? ((total_examples - total_failures).to_f / total_examples * 100) : 0
    puts "  Success Rate: #{success_rate.round(1)}%".colorize(total_failures == 0 ? :green : :red)
    
    puts "\n#{total_failures == 0 ? '✅ All tests passed!' : '❌ Some tests failed'}"
    puts "=" * 60
    
    # Performance summary
    if results[:agent] && results[:agent][:duration]
      puts "\n⚡ Performance Notes:"
      puts "  Test Agent completed in #{results[:agent][:duration].round(2)}s"
    end
    
    puts "\nTest completed at #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
  end
end

# Run the test suite
if __FILE__ == $0
  runner = MessagingTestRunner.new
  runner.run
end