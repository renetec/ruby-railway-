# Railway Deployment Workflow

## Repository Setup
- **Main development repo**: `renetec/ruby` (where we work)
- **Railway deployment repo**: `renetec/ruby-railway-` (what Railway monitors)
- Railway only deploys from the `ruby-railway-` repository

## Correct Deployment Process

### Daily Development (Development Branch)
```bash
# Work on development branch
git checkout development
# Make changes and test locally
git add .
git commit -m "Description of changes"
```

### Deploy to Railway Production
```bash
# 1. Merge to main branch
git checkout main
git merge development

# 2. Push to origin (main repo)
git push origin main

# 3. CRITICAL: Push to Railway repo for deployment
git push railway main
```

## Key Points
- Railway monitors the `ruby-railway-` repository, NOT the main `renetec/ruby` repo
- Always push to BOTH repositories: `origin main` and `railway main`
- The `git push railway main` command is essential for Railway deployment
- Without the railway push, changes won't deploy even if pushed to origin
- Railway deployment typically takes 1-2 minutes after successful push