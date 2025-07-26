# LeClub Ruby Application - Development Guide

## Project Overview
Rails community platform with user management, posts, events, forums, marketplace, business directory, and messaging system.

## Railway Deployment Setup
- **Production URL**: https://ruby-production-4cc9.up.railway.app
- **Main development repo**: `renetec/ruby` (where we work)
- **Railway deployment repo**: `renetec/ruby-railway-` (what Railway monitors)
- **Admin credentials**: admin@leclub.com / password123

### CRITICAL: Railway Deployment Process
Railway does NOT automatically deploy from the main `renetec/ruby` repository. You MUST push to the `ruby-railway-` repository for deployment to occur.

## Development Workflow (Option 2: Development Branch)

### Initial Setup (One-time)
```bash
# Create and switch to development branch
git checkout -b development

# Set development as your default working branch
git checkout development
```

### Daily Development Workflow
```bash
# 1. Start working on development branch
git checkout development

# 2. Make your changes locally and test at localhost:3000
# ... edit files, test features ...

# 3. Commit changes to development branch
git add .
git commit -m "Description of your changes"

# 4. When ready to deploy to Railway production:
git checkout main
git merge development
git push origin main

# 5. CRITICAL: Push to Railway repository for deployment
git push railway main

# 6. Railway deploys (1-2 minutes)

# 7. Switch back to development for next changes
git checkout development
```

### Key Benefits
- ✅ Keep Railway production stable
- ✅ Test multiple changes locally before deploying  
- ✅ Proper version control and history
- ✅ Work freely without affecting Railway
- ✅ Easy rollback if deployment issues occur

### Important Notes
- **main branch** = Railway production (never work directly on main)
- **development branch** = Your local development work
- Always test locally before merging to main
- **CRITICAL**: Railway only deploys from `ruby-railway-` repo, not the main `renetec/ruby` repo
- You MUST run `git push railway main` for Railway deployment to occur
- Local Docker changes won't affect Railway until you push to railway remote

## Project Structure
- Rails 7.2 application
- PostgreSQL database
- Tailwind CSS styling
- Devise authentication
- Action Cable for real-time features
- Kaminari pagination
- Image uploads with Active Storage

## Common Commands
```bash
# Local development
rails server              # Start local server
rails console            # Rails console
rails db:migrate         # Run migrations
rails db:seed            # Seed database

# Git workflow
git status               # Check current status
git log --oneline -10    # View recent commits
git checkout development # Switch to development
git checkout main        # Switch to main
```

## Troubleshooting
- If Railway deployment fails, check Railway logs
- If admin users page shows HTTP 500, the simplified view should prevent this
- For database issues, check DATABASE_URL environment variable
- Health check endpoint: /health

---
*Last updated: $(date)*