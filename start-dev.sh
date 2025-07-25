#!/bin/bash

# Cross-platform development startup script
# Works on both Windows WSL2 and Ubuntu

echo "🚀 Starting LeClub Development Environment..."

# Detect OS
if grep -q Microsoft /proc/version 2>/dev/null; then
    echo "📍 Detected: Windows WSL2"
    export DOCKER_HOST_IP=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
else
    echo "📍 Detected: Linux"
    export DOCKER_HOST_IP="127.0.0.1"
fi

echo "🔧 Docker Host IP: $DOCKER_HOST_IP"

# Check if .env exists, if not copy from example
if [ ! -f .env ]; then
    echo "📄 Creating .env file from .env.example..."
    cp .env.example .env
fi

# Start Docker Compose
echo "🐳 Starting Docker containers..."
docker-compose -f docker-compose.dev.yml up -d

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until docker-compose -f docker-compose.dev.yml exec -T leclub_db_dev pg_isready -U leclub > /dev/null 2>&1; do
    sleep 1
done

echo "✅ PostgreSQL is ready!"

# Check if database exists
if ! docker-compose -f docker-compose.dev.yml exec -T leclub_db_dev psql -U leclub -lqt | cut -d \| -f 1 | grep -qw leclub_development; then
    echo "📊 Creating database..."
    docker-compose -f docker-compose.dev.yml exec -T leclub_web_dev rails db:create
    docker-compose -f docker-compose.dev.yml exec -T leclub_web_dev rails db:migrate
    docker-compose -f docker-compose.dev.yml exec -T leclub_web_dev rails db:seed
fi

echo "✨ Development environment is ready!"
echo "🌐 Access your app at: http://localhost:3005"
echo "📧 Admin login: admin@leclub.com / password123"
echo ""
echo "📝 Useful commands:"
echo "  View logs:        docker-compose -f docker-compose.dev.yml logs -f leclub_web_dev"
echo "  Rails console:    docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails console"
echo "  Stop everything:  docker-compose -f docker-compose.dev.yml down"