#!/bin/bash
set -e

# Install gems if needed
echo "Installing gems..."
bundle install

# Setup database if needed
echo "Setting up database..."
bundle exec rails db:prepare || bundle exec rails db:create db:migrate

# Start the Rails server
echo "Starting Rails server..."
exec bundle exec rails server -b '0.0.0.0'