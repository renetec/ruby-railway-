#!/bin/bash

# Docker Test Runner for Messaging System
# This script sets up the test environment and runs the messaging test suite in Docker

set -e

echo "🐳 Docker Messaging Test Runner"
echo "==============================="

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed"
    exit 1
fi

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up test containers..."
    docker-compose down test 2>/dev/null || true
}

# Trap cleanup on exit
trap cleanup EXIT

echo "🏗️  Building test container..."
docker-compose build test

echo "🗄️  Setting up test database..."
# First, ensure the database service is running
docker-compose up -d db redis

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Setup test database
echo "📋 Creating and migrating test database..."
docker-compose run --rm test bash -c "
    echo 'Setting up test database...'
    RAILS_ENV=test bundle exec rails db:create db:migrate
    echo 'Test database setup complete!'
"

echo "🧪 Running messaging test suite..."
echo "=================================="

# Run the complete test suite
docker-compose run --rm test

# Check exit code
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All messaging tests completed successfully!"
    echo "🎉 The messaging system is working correctly in Docker"
else
    echo ""
    echo "❌ Some tests failed (exit code: $TEST_EXIT_CODE)"
    echo "📋 Check the test output above for details"
fi

echo ""
echo "🐳 Docker test run completed"
echo "==============================="

exit $TEST_EXIT_CODE