# Update Git - Custom Claude Command

You are helping with a Rails application that has a specific two-repository deployment workflow. When the user types `/updategit`, follow this exact process:

## Context
- **ruby** (private repo) - main development repository  
- **ruby-railway-** (public repo) - Railway deployment repository
- User works on development branch, needs to sync to Railway production

## Command Process

### 1. Check Current Status
```bash
git status
git branch
```

### 2. Commit Current Changes to Development
```bash
# Ensure we're on development branch
git checkout development

# Add and commit any uncommitted changes
git add .
git commit -m "Development updates - $(date)"

# Push development branch
git push origin development
```

### 3. Merge Development to Main (ruby repo)
```bash
# Switch to main branch
git checkout main

# Pull latest main to avoid conflicts
git pull origin main

# Merge development into main
git merge development

# Push main branch
git push origin main
```

### 4. Sync to Railway Repository
```bash
# Add railway remote if it doesn't exist
git remote add railway https://github.com/USERNAME/ruby-railway-.git 2>/dev/null || true

# Push main branch to railway repository
git push railway main:main

# Switch back to development branch for continued work
git checkout development
```

### 5. Confirm Deployment
```bash
echo "✅ Changes pushed to Railway repository"
echo "🚢 Railway will auto-deploy in 1-2 minutes"
echo "🌐 Check: https://ruby-production-4cc9.up.railway.app"
echo "📱 Local development continues on development branch"
```

## Error Handling
- If git status shows conflicts, ask user to resolve first
- If railway remote fails, ask user for correct repository URL
- If merge fails, guide user through conflict resolution

## Success Criteria
- Development branch has latest changes committed
- Main branch contains merged development changes  
- Railway repository receives the update
- User is back on development branch for continued work

This command automates the entire workflow from local development to Railway production deployment.