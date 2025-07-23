# Railway Deployment Guide for Ruby on Rails Application

This guide provides step-by-step instructions for deploying your Ruby on Rails application to Railway.

## Prerequisites

- [ ] Railway account (sign up at https://railway.com)
- [ ] GitHub account (for GitHub deployment method)
- [ ] Railway CLI installed (optional, for CLI deployment)
  ```bash
  npm install -g @railway/cli
  ```

## Pre-Deployment Checklist

- [ ] Ensure your Ruby version is specified in `Gemfile` (currently: Ruby 3.2.8)
- [ ] Database configuration uses environment variables
- [ ] Rails master key is ready for production
- [ ] All dependencies are listed in `Gemfile`
- [ ] Application runs locally without errors

## Deployment Methods

### Method 1: Deploy from GitHub (Recommended)

#### Step 1: Push Code to GitHub
- [ ] Initialize git repository (if not already done)
  ```bash
  git init
  git add .
  git commit -m "Initial commit"
  ```
- [ ] Create repository on GitHub
- [ ] Push code to GitHub
  ```bash
  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
  git push -u origin main
  ```

#### Step 2: Connect to Railway
- [ ] Log in to Railway Dashboard
- [ ] Click "New Project"
- [ ] Select "Deploy from GitHub repo"
- [ ] Authorize Railway to access your GitHub account
- [ ] Select your repository
- [ ] Click "Deploy Now"

### Method 2: Deploy with Railway CLI

#### Step 1: Login to Railway
- [ ] Open terminal in project directory
- [ ] Run `railway login`

#### Step 2: Initialize Project
- [ ] Run `railway init`
- [ ] Enter project name when prompted

#### Step 3: Deploy
- [ ] Run `railway up`
- [ ] Wait for deployment to complete

### Method 3: Deploy from Docker Image

#### Step 1: Build Docker Image
- [ ] Create Dockerfile (if not exists)
- [ ] Build image: `docker build -t your-app-name .`
- [ ] Push to registry (Docker Hub, GitHub Container Registry, etc.)

#### Step 2: Deploy on Railway
- [ ] Create new project on Railway
- [ ] Choose "Docker Image"
- [ ] Enter image name (e.g., `username/your-app-name`)
- [ ] Click "Deploy"

## Configuration

### Environment Variables
- [ ] Set up required environment variables in Railway:
  ```
  DATABASE_URL=postgresql://...
  RAILS_MASTER_KEY=your-master-key
  RAILS_ENV=production
  PORT=$PORT
  REDIS_URL=redis://...
  AWS_ACCESS_KEY_ID=your-key (if using S3)
  AWS_SECRET_ACCESS_KEY=your-secret (if using S3)
  AWS_REGION=your-region (if using S3)
  AWS_BUCKET=your-bucket (if using S3)
  ```

### Database Setup
- [ ] Add PostgreSQL service to your Railway project
  - Click "New" → "Database" → "Add PostgreSQL"
  - Railway will automatically set `DATABASE_URL`

### Redis Setup (for ActionCable/Sidekiq)
- [ ] Add Redis service to your Railway project
  - Click "New" → "Database" → "Add Redis"
  - Railway will automatically set `REDIS_URL`

## Post-Deployment Tasks

### Database Migration
- [ ] Run migrations after first deployment
  ```bash
  railway run rails db:migrate
  ```

### Asset Precompilation
- [ ] Verify assets are compiled (happens automatically with Nixpacks)

### Custom Domain
- [ ] Generate Railway domain
  - Go to Settings → Networking → Generate Domain
- [ ] Configure custom domain (optional)
  - Add CNAME record pointing to Railway domain
  - Add custom domain in Railway settings

### Health Checks
- [ ] Verify health check endpoint is working
  - Currently configured as `/` with 600s timeout

## Monitoring & Maintenance

### Logs
- [ ] Check deployment logs in Railway dashboard
- [ ] Monitor application logs for errors

### Scaling
- [ ] Adjust replica count in service settings (if needed)
- [ ] Configure resource limits (CPU/Memory)

### Backups
- [ ] Set up database backups (PostgreSQL service includes automatic backups on Pro plan)

## Troubleshooting

### Common Issues

1. **Build Failures**
   - [ ] Check Nixpacks configuration in `nixpacks.toml`
   - [ ] Verify all gems can be installed
   - [ ] Check Ruby version compatibility

2. **Database Connection Issues**
   - [ ] Ensure `DATABASE_URL` is set correctly
   - [ ] Verify PostgreSQL service is running
   - [ ] Check database credentials

3. **Asset Pipeline Issues**
   - [ ] Verify `rails assets:precompile` runs successfully
   - [ ] Check for missing JavaScript/CSS dependencies

4. **Memory Issues**
   - [ ] Monitor memory usage in Railway dashboard
   - [ ] Optimize Puma worker configuration
   - [ ] Consider upgrading to higher resource tier

### Useful Commands

```bash
# View logs
railway logs

# Run Rails console
railway run rails console

# Run database migrations
railway run rails db:migrate

# Check environment variables
railway variables

# Restart service
railway restart
```

## Additional Resources

- Railway Documentation: https://docs.railway.com
- Railway Templates: https://railway.com/templates
- Community Support: https://discord.gg/railway
- Status Page: https://status.railway.com

## Project-Specific Notes

- This project uses Nixpacks builder (configured in `railway.json`)
- PostgreSQL is required (gem 'pg' in Gemfile)
- Redis is recommended for ActionCable and Sidekiq
- Current start command: `bin/rails server -b :: -p $PORT`