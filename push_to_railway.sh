#!/bin/bash

# Go to the railway directory
cd ../ruby-railway

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Complete Rails app with modern 2025 design

- Modern glass morphism login design
- Full navigation layout  
- All Rails framework files included
- Railway-optimized configuration"

# Add remote
git remote add origin https://github.com/renetec/ruby-railway.git

# Push to main branch (force push to overwrite empty repo)
git branch -M main
git push -u origin main --force

echo "All files pushed to GitHub repository!"