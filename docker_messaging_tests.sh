#!/bin/bash

# Comprehensive Docker-based messaging test runner
# This script runs all messaging tests inside the Docker container

set -e

echo "🐳 Docker Messaging Test Suite"
echo "==============================="

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed"
    exit 1
fi

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up..."
    docker-compose down test 2>/dev/null || true
}

# Trap cleanup on exit
trap cleanup EXIT

echo "🏗️  Building test container..."
docker-compose build test

echo "🗄️  Setting up test environment..."
# Ensure services are running
docker-compose up -d db redis

# Wait for database
echo "⏳ Waiting for database..."
sleep 5

echo "🧪 Running comprehensive messaging tests..."

# Run the complete test suite inside Docker
docker-compose run --rm test bash -c "
echo '🔧 Setting up Rails test environment...'
export RAILS_ENV=test
cd /app

echo '📋 Creating test database...'
bundle exec rails db:create db:migrate

echo '📁 Creating RSpec configuration...'
mkdir -p spec
cat > spec/rails_helper.rb << 'EOF'
require 'rspec/rails'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('Rails is running in production mode!') if Rails.env.production?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  
  # Include Factory Bot methods
  config.include FactoryBot::Syntax::Methods
  
  # Configure Capybara for system tests
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  # Configure for Docker Chrome
  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1400,1400')
    
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end
EOF

cat > spec/spec_helper.rb << 'EOF'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
EOF

echo '🧪 Starting test execution...'
echo '=============================================='

# Start Xvfb for browser tests
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=\$!

# Function to cleanup Xvfb
cleanup_xvfb() {
    if [ ! -z \"\$XVFB_PID\" ]; then
        kill \$XVFB_PID 2>/dev/null || true
    fi
}
trap cleanup_xvfb EXIT

sleep 2

echo '📋 Running Unit Tests...'
echo '------------------------'
bundle exec rspec enhanced_message_spec.rb --format documentation
unit_exit=\$?

echo ''
echo '🖥️  Running System Tests...'
echo '-------------------------'
bundle exec rspec messaging_system_spec.rb --format documentation
system_exit=\$?

echo ''
echo '🔔 Running Notification Tests...'
echo '------------------------------'
bundle exec rspec notification_system_spec.rb --format documentation
notification_exit=\$?

echo ''
echo '🤖 Running Test Agent...'
echo '----------------------'
ruby messaging_test_agent.rb
agent_exit=\$?

echo ''
echo '📊 TEST SUMMARY'
echo '==============='
echo \"Unit Tests: \$([ \$unit_exit -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')\"
echo \"System Tests: \$([ \$system_exit -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')\"
echo \"Notification Tests: \$([ \$notification_exit -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')\"
echo \"Test Agent: \$([ \$agent_exit -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')\"

total_failures=\$((unit_exit + system_exit + notification_exit + agent_exit))
if [ \$total_failures -eq 0 ]; then
    echo ''
    echo '🎉 All messaging tests PASSED!'
    echo 'The messaging system is working correctly in Docker!'
else
    echo ''
    echo \"❌ \$total_failures test suite(s) failed\"
fi

exit \$total_failures
"

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Docker messaging tests completed successfully!"
else
    echo "❌ Some tests failed (exit code: $TEST_EXIT_CODE)"
fi

echo "🐳 Docker test execution completed"
echo "==============================="

exit $TEST_EXIT_CODE