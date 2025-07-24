#!/usr/bin/env ruby
# Docker Test Environment Setup and Verification

require 'fileutils'
require 'colorize'

class DockerTestSetup
  def initialize
    @issues = []
  end

  def run
    puts "🔍 Docker Test Environment Verification".colorize(:blue).bold
    puts "=" * 50

    check_required_files
    check_test_dependencies
    create_test_data
    verify_browser_setup
    
    if @issues.empty?
      puts "\n✅ Docker test environment is ready!".colorize(:green).bold
      puts "📝 Run tests with: ./docker_test_runner.sh"
    else
      puts "\n❌ Issues found:".colorize(:red).bold
      @issues.each { |issue| puts "  - #{issue}".colorize(:red) }
      exit(1)
    end
  end

  private

  def check_required_files
    puts "\n📋 Checking required test files..."
    
    required_files = [
      'messaging_test_factories.rb',
      'enhanced_message_spec.rb',
      'messaging_system_spec.rb',
      'notification_system_spec.rb',
      'messaging_test_agent.rb',
      'run_messaging_tests.rb',
      'Dockerfile.test',
      'docker_test_runner.sh'
    ]
    
    required_files.each do |file|
      if File.exist?(file)
        puts "  ✅ #{file}".colorize(:green)
      else
        @issues << "Missing required file: #{file}"
        puts "  ❌ #{file}".colorize(:red)
      end
    end
  end

  def check_test_dependencies
    puts "\n🔧 Checking test dependencies..."
    
    begin
      require 'bundler'
      
      required_gems = ['rspec-rails', 'factory_bot_rails', 'capybara', 'selenium-webdriver']
      
      required_gems.each do |gem_name|
        begin
          gem gem_name
          puts "  ✅ #{gem_name}".colorize(:green)
        rescue Gem::LoadError
          @issues << "Missing gem: #{gem_name}"
          puts "  ❌ #{gem_name}".colorize(:red)
        end
      end
    rescue LoadError
      @issues << "Bundler not available"
    end
  end

  def create_test_data
    puts "\n📊 Setting up test data structure..."
    
    # Ensure directories exist for test output
    ['tmp', 'tmp/test_reports', 'log'].each do |dir|
      unless Dir.exist?(dir)
        FileUtils.mkdir_p(dir)
        puts "  ✅ Created #{dir}".colorize(:green)
      else
        puts "  ✅ #{dir} exists".colorize(:green)
      end
    end
  end

  def verify_browser_setup
    puts "\n🌐 Browser setup (Docker-specific)..."
    
    # In Docker, we'll check if Chrome-related env vars are set
    if ENV['CHROME_BIN'] && ENV['CHROME_PATH']
      puts "  ✅ Chrome environment variables set".colorize(:green)
    else
      puts "  ℹ️  Chrome environment will be set in Docker".colorize(:yellow)
    end
    
    puts "  ℹ️  Xvfb display will be started in Docker container".colorize(:yellow)
  end
end

# Run the setup if this script is executed directly
if __FILE__ == $0
  setup = DockerTestSetup.new
  setup.run
end