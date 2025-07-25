# Rails App Deployment Fix on Dokploy

## Problem Summary
The Rails application deployed on Dokploy was not accessible due to database connection issues. The app was trying to connect to PostgreSQL on localhost instead of the correct Docker service.

## Issues Identified
1. Rails app couldn't connect to PostgreSQL database
2. Database host was set to `localhost` instead of the Docker service name
3. Database credentials were incorrect (using `root/password` instead of Dokploy's PostgreSQL credentials)
4. Container wasn't on the correct Docker network

## Solution Steps

### 1. Identified the PostgreSQL Service
```bash
docker service ls | grep postgres
# Found: dokploy-postgres
```

### 2. Retrieved PostgreSQL Credentials
```bash
docker exec dokploy-postgres.1.6f8cbszpwm67wfb46d7c7i85v env | grep POSTGRES
# Found:
# POSTGRES_USER=dokploy
# POSTGRES_PASSWORD=amukds4wi9001583845717ad2
# POSTGRES_DB=dokploy
```

### 3. Restarted Rails Container with Correct Configuration
```bash
# Stop and remove the old container
docker stop leclub-manual && docker rm leclub-manual

# Run with correct database URL and network
docker run -d --name leclub-manual \
  -p 9999:3000 \
  --network dokploy-network \
  -e DATABASE_URL="postgresql://dokploy:amukds4wi9001583845717ad2@dokploy-postgres:5432/pacomien_production" \
  -e RAILS_ENV=production \
  leclub-rails-yb4auv:latest
```

### 4. Created Database and Ran Migrations
```bash
# Create the database
docker exec leclub-manual /bin/bash -l -c 'bundle exec rails db:create'

# Run migrations
docker exec leclub-manual /bin/bash -l -c 'bundle exec rails db:migrate'
```

## Final Working Configuration
- **Container Name**: leclub-manual
- **Port Mapping**: 9999:3000
- **Network**: dokploy-network
- **Database Host**: dokploy-postgres
- **Database User**: dokploy
- **Database Password**: amukds4wi9001583845717ad2
- **Database Name**: pacomien_production

## Access URL
The application is now accessible at: `http://192.168.0.114:9999`

## Key Takeaways
1. Always use Docker service names for inter-container communication, not localhost
2. Ensure containers are on the same Docker network for communication
3. Use the correct database credentials from the PostgreSQL container environment
4. The `/bin/bash -l -c` wrapper is needed for Rails commands to load the proper environment