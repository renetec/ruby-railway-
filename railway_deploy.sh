#!/bin/bash
# Railway deployment script

echo "Starting deployment..."

# Run migrations
echo "Running database migrations..."
bundle exec rails db:migrate

# Precompile assets
echo "Precompiling assets..."
bundle exec rails assets:precompile

echo "Deployment complete!"