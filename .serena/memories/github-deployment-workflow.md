# GitHub Deployment Workflow for LeClub Ruby App

## Two-Repository Setup
- **ruby** (private repo) - main development work, has development branch
- **ruby-railway-** (public repo) - Railway deployment target, Railway watches this repo

## Key Issue Understanding
User was confused why localhost (development mode) looked different from Railway/NAS (production mode). The real issue is that changes made locally in development branch don't automatically appear on Railway because:

1. Local changes are in `ruby` repo development branch
2. Railway deploys from `ruby-railway-` repo main branch  
3. These are separate repositories that need manual syncing

## Complete Sync Process
1. development branch (local) → main branch (ruby repo)
2. main branch (ruby repo) → main branch (ruby-railway- repo) 
3. Railway auto-deploys from ruby-railway- repo

## User's Goal
When user fixes things locally, they want it to appear on Railway and NAS automatically. This requires the two-step sync process above.

## Solution Created
- githubflow.md documentation
- /updategit custom command to automate the entire workflow
- Memory documentation for future reference