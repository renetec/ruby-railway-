# GitHub Flow Documentation - LeClub Ruby App

## Repository Setup
We have **two separate GitHub repositories**:

1. **`ruby`** (Private) - Main development repository
   - Branches: main, development, development-sync, pacomien, pacomiengit
   - This is where all development work happens
   - Contains the most up-to-date code

2. **`ruby-railway-`** (Public) - Railway deployment repository
   - Branches: main, ruby-railway-
   - This is what Railway monitors for deployments
   - Must be kept in sync with ruby repo main branch

## Current Workflow

### Step 1: Local Development
```bash
# Work on development branch locally
git checkout development
# Make your changes, test at localhost:3005
```

### Step 2: Commit Changes to Development
```bash
# Add and commit your changes
git add .
git commit -m "Description of changes made"
git push origin development
```

### Step 3: Merge to Main Branch (ruby repo)
```bash
# Switch to main and merge development
git checkout main
git merge development
git push origin main
```

### Step 4: Sync to Railway Repository
```bash
# Add railway remote if not already added
git remote add railway https://github.com/yourusername/ruby-railway-.git

# Push main branch to railway repository
git push railway main:main
```

### Step 5: Railway Auto-Deployment
- Railway automatically detects the push to ruby-railway- repo
- Railway rebuilds and deploys (takes 1-2 minutes)
- Your live site at https://ruby-production-4cc9.up.railway.app updates

## Environments After Sync

- **Local Docker** (localhost:3005) - Development mode with latest changes
- **Railway Production** - Production mode with same code from main
- **NAS/Dokploy** - Would need manual rebuild to get latest code

## Important Notes

1. **Always work on development branch locally**
2. **Never push directly to main** - always merge from development
3. **Railway only sees ruby-railway- repo** - not the private ruby repo
4. **Two-step sync required**: ruby main → ruby-railway- main → Railway
5. **Test locally first** before pushing to production

## Troubleshooting

- If Railway doesn't update: Check that ruby-railway- repo received the push
- If changes don't appear: Verify you merged development to main first
- If build fails on Railway: Check Railway logs for specific errors

## One-Command Solution
Use the custom `/updategit` command to automate this entire workflow.

---
*This workflow ensures all three environments (local, Railway, NAS) can stay in sync with your development changes.*