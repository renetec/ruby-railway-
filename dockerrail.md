# Docker Rails Deployment Guide - Pacomien Project

## Why Docker + Ruby on Rails is Complicated

1. **Multiple Dependencies**: Ruby, PostgreSQL, Redis, Node.js, system libraries
2. **Ruby Version Mismatches**: Gemfile vs Docker image versions  
3. **Database Setup**: PostgreSQL needs installation, configuration, and persistence
4. **Rails Secrets/Keys**: Encryption keys and credentials management
5. **PID File Issues**: Rails server.pid persists across container restarts
6. **Asset Pipeline**: Images, CSS, JavaScript compilation and serving
7. **File Sync Issues**: Changes made after Docker build aren't reflected
8. **Permission Problems**: File ownership between host and container
9. **Environment Variables**: Different configs for development/production
10. **Migration State**: Database migrations need to persist

## Complete Steps to Rebuild Docker for Rails

### Step 1: Fix Ruby Version Mismatch
```bash
# Check your system Ruby version
ruby --version  # Returns: ruby 3.2.3

# Update Gemfile to match Docker image version
# Change: ruby "3.2.3" 
# To: ruby "3.2.8"
```


# Clean up docker-compose services
docker-compose down --remove-orphans
```

### Step 3: Fix the Dockerfile
```dockerfile
FROM ruby:3.2-slim

# Install all dependencies including PostgreSQL
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    npm \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Setup PostgreSQL inside container
RUN service postgresql start && \
    sudo -u postgres createuser -s root && \
    sudo -u postgres createdb pacomien_development && \
    sudo -u postgres psql -c "ALTER USER root PASSWORD 'password';"

# Install bundler
RUN gem install bundler:2.4.22

# Copy and install gems
COPY Gemfile* ./
RUN bundle config set --local deployment false && \
    bundle install

# Copy application
COPY . .

# Environment variables
ENV PGHOST=localhost
ENV PGUSER=root
ENV PGPASSWORD=password
ENV PGPORT=5432
ENV RAILS_ENV=development
ENV SECRET_KEY_BASE=7cfe083fa7bfc2e791dc15a975f359a99510c53e072abf437d3189802281b1d57cfe083fa7bfc2e791dc15a975f359a99510c53e072abf437d3189802281b1d5

# Remove old credentials
RUN rm -f config/credentials.yml.enc config/master.key

# Create startup script
RUN echo '#!/bin/bash\nset -e\necho "Starting PostgreSQL..."\nservice postgresql start\necho "Waiting for PostgreSQL to be ready..."\nsleep 10\necho "Setting up database..."\nif ! bundle exec rails db:version >/dev/null 2>&1; then\n  echo "Creating and migrating database..."\n  bundle exec rails db:create || true\n  bundle exec rails db:migrate || true\n  echo "Seeding database..."\n  bundle exec rails db:seed || true\nfi\necho "Starting Rails server..."\nbundle exec rails server -b "0.0.0.0" -p 3000' > /start.sh && \
    chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
```

### Step 4: Build and Run Standalone Container
```bash
# Build the Docker image
docker build -t pacomien .

# Run container with PID cleanup
docker run -d --name pacomien -p 3000:3000 \
  -e RAILS_ENV=development \
  pacomien sh -c "rm -f /app/tmp/pids/server.pid && /start.sh"
```

### Step 5: Run Migrations Manually
```bash
# If migrations haven't run automatically
docker exec pacomien bundle exec rails db:migrate

# Seed the database
docker exec pacomien bundle exec rails db:seed
```

### Step 6: Handle Missing Files (Common Issue)
```bash
# If you added files after building Docker image:
# 1. Copy shared partials
docker exec pacomien mkdir -p /app/app/views/shared
docker cp app/views/shared/_page_header_with_logo.html.erb pacomien:/app/app/views/shared/

# 2. Copy assets
docker exec pacomien mkdir -p /app/app/assets/images
docker cp app/assets/images/Pacomien.jpg pacomien:/app/app/assets/images/

# 3. Copy to public for production
docker exec pacomien cp /app/app/assets/images/Pacomien.jpg /app/public/
```

### Step 7: Alternative - Docker Compose Setup
```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: leclub_development
    ports:
      - "5433:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6380:6379"

  web:
    build: .
    command: ./entrypoint.sh
    volumes:
      - .:/app  # This syncs all files automatically!
      - bundle_cache:/usr/local/bundle
    ports:
      - "3001:3000"
    depends_on:
      - db
      - redis
    environment:
      DATABASE_HOST: db
      DATABASE_USERNAME: postgres
      DATABASE_PASSWORD: password
      REDIS_URL: redis://redis:6379/0
      RAILS_ENV: development

volumes:
  postgres_data:
  bundle_cache:
```

### Step 8: Create entrypoint.sh for docker-compose
```bash
#!/bin/bash
set -e

echo "Installing gems..."
bundle install

echo "Setting up database..."
bundle exec rails db:prepare || bundle exec rails db:create db:migrate

echo "Starting Rails server..."
exec bundle exec rails server -b '0.0.0.0'
```

## Common Issues and Solutions

### Issue 1: PID File Already Exists
```bash
# Error: A server is already running (pid: 44, file: /app/tmp/pids/server.pid)
# Solution:
docker exec pacomien rm -f /app/tmp/pids/server.pid
docker restart pacomien
```

### Issue 2: Migrations Not Running
```bash
# Error: Migrations are pending
# Solution:
docker exec pacomien bundle exec rails db:migrate
docker exec pacomien bundle exec rails db:seed
```

### Issue 3: Assets Not Found
```bash
# Error: The asset "Pacomien.jpg" is not present in the asset pipeline
# Solutions:
# 1. Rebuild image after adding assets
docker build -t pacomien .

# 2. Or copy assets manually
docker cp app/assets/images/Pacomien.jpg pacomien:/app/public/
```

### Issue 4: Ruby Version Mismatch
```bash
# Error: Your Ruby version is 3.2.8, but your Gemfile specified 3.2.3
# Solution: Update Gemfile to match Docker image
ruby "3.2.8"
```

### Issue 5: Missing Gems
```bash
# Error: Could not find kamal-2.7.0, bcrypt_pbkdf-1.1.1...
# Solution:
docker exec pacomien bundle install
```

### Issue 6: Missing Helper Methods
```bash
# Error: undefined method `get_event_emoji' for #<ActionView::Base:0x0000000001e118>
# This happens when helper methods are added after Docker image is built
# Solution: Copy updated helper files
docker cp app/helpers/application_helper.rb pacomien:/app/app/helpers/

# The missing helper method for event emojis:
def get_event_emoji(category)
  case category.to_s
  when 'community' then '🏘️'
  when 'business' then '💼'
  when 'education' then '📚'
  when 'entertainment' then '🎭'
  when 'sports' then '⚽'
  when 'health' then '🏥'
  when 'technology' then '💻'
  when 'culture' then '🎨'
  when 'volunteer' then '🤝'
  else '📅'
  end
end
```

### Issue 7: Asset Pipeline Not Precompiled - All Pages Affected
```bash
# Error: The asset "pacomien-logo.jpg" is not present in the asset pipeline
# This happens when assets are not properly precompiled for production-like environments
# Even though the asset file exists, Rails can't find it without precompilation

# Root cause: Assets were not precompiled after being added to the container
# This affected ALL pages using the Pacomien.jpg logo

# Steps to fix:
# 1. Ensure asset file is in container
docker cp app/assets/images/Pacomien.jpg pacomien:/app/app/assets/images/

# 2. CRITICAL: Precompile assets inside container
docker exec pacomien bundle exec rails assets:precompile

# 3. Restart container to apply precompiled assets
docker restart pacomien

# 4. Copy any updated view files to container (CRITICAL STEP)
docker cp app/views/devise/sessions/new.html.erb pacomien:/app/app/views/devise/sessions/new.html.erb
docker cp app/views/devise/registrations/new.html.erb pacomien:/app/app/views/devise/registrations/new.html.erb

# 5. IMPORTANT: Recompile assets after copying updated views
docker exec pacomien bundle exec rails assets:precompile

# The precompilation step creates:
# - /app/public/assets/Pacomien-[hash].jpg (fingerprinted asset)
# - /app/public/assets/application-[hash].css (compiled CSS)
# - Manifest file for Rails to locate assets

# Note: In production-like Docker environments, assets MUST be precompiled
# Without this step, image_tag cannot locate any assets in the pipeline
```

## Quick Reference Commands

```bash
# Build
docker build -t pacomien .

# Run standalone
docker run -d --name pacomien -p 3000:3000 pacomien

# Run with docker-compose
docker-compose up -d

# Check logs
docker logs pacomien --tail 50
docker-compose logs web

# Access container
docker exec -it pacomien bash

# Run Rails commands
docker exec pacomien bundle exec rails console
docker exec pacomien bundle exec rails db:migrate
docker exec pacomien bundle exec rails db:seed

# Stop and remove
docker stop pacomien && docker rm pacomien
docker-compose down

# Rebuild without cache
docker build --no-cache -t pacomien .
```

## Best Practices

1. **Use Docker Compose** for development - it handles file syncing automatically
2. **Use Standalone Container** for production-like testing
3. **Always remove PID files** in startup scripts
4. **Set SECRET_KEY_BASE** properly for each environment  
5. **Use volumes** for database persistence
6. **Cache bundle install** by copying Gemfile first
7. **Handle migrations** in startup script with checks
8. **Test locally first** before deploying

## Production Considerations

1. Use multi-stage builds to reduce image size
2. Don't include development/test gems
3. Precompile assets: `rails assets:precompile`
4. Use environment-specific configs
5. Never commit secrets to Docker images
6. Use external database instead of PostgreSQL in container
7. Set up proper logging and monitoring

### Issue 8: Asset Pipeline Precompilation Required for All Assets
```bash
# Error: "The asset [filename] is not present in the asset pipeline" affecting ALL pages
# This is the most critical issue that affects every page using any assets (images, CSS, JS)

# What happened:
# - User reported "all pages have this issue" with asset loading
# - Even after copying assets to container, Rails couldn't find them
# - The container was running in a production-like environment where assets need precompilation

# Root cause analysis:
# 1. Assets existed in /app/app/assets/images/Pacomien.jpg ✓
# 2. Assets were copied to /app/public/Pacomien.jpg ✓  
# 3. But Rails asset pipeline couldn't locate them ✗
# 4. Missing step: Asset precompilation creates the manifest and fingerprinted files

# The solution:
docker exec pacomien bundle exec rails assets:precompile
docker restart pacomien

# What this does:
# 1. Compiles all assets from app/assets/ into public/assets/
# 2. Creates fingerprinted versions (e.g., Pacomien-37f0639b5241fcec.jpg)
# 3. Generates manifest.json for Rails to find assets
# 4. Compiles and minifies CSS/JS files

# Output after successful precompilation:
# Writing /app/public/assets/Pacomien-37f0639b5241fcec7d424db2fc97cf67d6c89c42accb15998f866aa458753385.jpg
# Writing /app/public/assets/application-e514f89a9a4651aca2d96ffab05364390322dff45e34bc94ca8e3ee9d2af7e12.css

# Why this is essential in Docker:
# - Docker containers often run in production-like mode
# - Rails development vs production asset handling differs significantly
# - Without precompilation, image_tag() helper cannot resolve asset paths
# - This affects ALL assets: images, stylesheets, JavaScript files

# Prevention for future:
# Add asset precompilation to Dockerfile or startup script:
# RUN bundle exec rails assets:precompile (in Dockerfile)
# OR
# Add to /start.sh: bundle exec rails assets:precompile
```

### Issue 9: Missing Admin Namespace Controllers
```bash
# Error: uninitialized constant Admin when accessing /admin route
# This happens when routes.rb defines admin namespace but controllers don't exist

# Root cause:
# - Routes defined: namespace :admin with dashboard, users, posts, events, forum_categories
# - But /app/app/controllers/admin/ directory was missing
# - Rails couldn't find Admin::DashboardController, Admin::UsersController, etc.

# What was missing:
# - Admin namespace directory structure
# - Individual admin controllers inheriting from AdminController

# Solution steps:
# 1. Create admin controllers directory
mkdir -p app/controllers/admin

# 2. Create all required admin controllers:
# - app/controllers/admin/dashboard_controller.rb
# - app/controllers/admin/users_controller.rb  
# - app/controllers/admin/posts_controller.rb
# - app/controllers/admin/events_controller.rb
# - app/controllers/admin/forum_categories_controller.rb

# 3. Copy to Docker container
docker exec pacomien mkdir -p /app/app/controllers/admin
docker cp app/controllers/admin/ pacomien:/app/app/controllers/

# Note: All admin controllers inherit from AdminController which:
# - Requires authentication (before_action :authenticate_user!)
# - Checks admin role (before_action :ensure_admin!)
# - Provides basic admin functionality and security

# The admin routes now work:
# - /admin → Admin::DashboardController#index
# - /admin/users → Admin::UsersController#index
# - /admin/posts → Admin::PostsController#index
# - etc.

# Additional step: Create admin view templates
# Controllers need corresponding view templates to render HTML
mkdir -p app/views/admin/dashboard
mkdir -p app/views/admin/users
# Create admin view templates:
# - app/views/admin/dashboard/index.html.erb (admin dashboard view)
# - app/views/admin/users/index.html.erb (users management view)
docker exec pacomien mkdir -p /app/app/views/admin/dashboard /app/app/views/admin/users
docker cp app/views/admin/dashboard/index.html.erb pacomien:/app/app/views/admin/dashboard/
docker cp app/views/admin/users/index.html.erb pacomien:/app/app/views/admin/users/
```

### Issue 10: Missing Job Form Views
```bash
# Error: JobsController#new is missing a template for request formats: text/html
# This happens when controller actions exist but corresponding view templates are missing

# Root cause:
# - JobsController has new, edit, create, update actions
# - But app/views/jobs/ only had index.html.erb and show.html.erb
# - Missing new.html.erb (and potentially edit.html.erb) templates

# Solution: Create missing job view templates
# Create app/views/jobs/new.html.erb with comprehensive job posting form
docker cp app/views/jobs/new.html.erb pacomien:/app/app/views/jobs/

# The new job form includes:
# - Job title, company name, location fields
# - Job type dropdown (full-time, part-time, contract, etc.)
# - Salary range (min/max) inputs
# - Rich text areas for description, requirements, benefits
# - Application instructions field
# - Status selection (draft/published)
# - Glassmorphism styling matching site design
# - Form validation error display
# - Helpful tips section for better job postings

# Note: Similar approach needed for other missing view templates
# Always ensure controller actions have corresponding view files
```

## Summary of What We Did

1. **Initial Issue**: Ruby version mismatch (3.2.3 vs 3.2.8)
2. **Fixed Gemfile**: Updated Ruby version to match Docker
3. **Built Docker Image**: Created comprehensive Dockerfile with PostgreSQL
4. **Handled PID Issues**: Added cleanup in startup command
5. **Ran Migrations**: Executed manually when automatic run failed
6. **Fixed Missing Files**: Copied shared partials and assets
7. **Fixed Missing Helper Methods**: Added get_event_emoji helper for events page
8. **CRITICAL: Fixed Asset Pipeline**: Precompiled all assets to resolve "all pages have this issue"
9. **Created Documentation**: This comprehensive guide

The key lesson: Docker + Rails complexity comes from managing multiple services, file synchronization, and state persistence. Using docker-compose with volumes is much easier for development!

## Complete List of Files to Copy After Docker Build

If you make changes after building the Docker image, copy these files:

```bash
# Helper files
docker cp app/helpers/application_helper.rb pacomien:/app/app/helpers/

# View partials
docker exec pacomien mkdir -p /app/app/views/shared
docker cp app/views/shared/_page_header_with_logo.html.erb pacomien:/app/app/views/shared/

# Assets
docker exec pacomien mkdir -p /app/app/assets/images
docker cp app/assets/images/Pacomien.jpg pacomien:/app/app/assets/images/
docker exec pacomien cp /app/app/assets/images/Pacomien.jpg /app/public/

# Updated views (if modified)
docker cp app/views/devise/sessions/new.html.erb pacomien:/app/app/views/devise/sessions/
```