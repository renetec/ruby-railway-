# Quick Start Guide - LeClub Development on New Computer

## Prerequisites
- Docker installed (Docker Desktop for Windows/Mac, or Docker Engine for Linux)
- Git installed
- Terminal/Command Line access

## Step-by-Step Setup

### 1. Clone the Repository
```bash
git clone https://github.com/renetec/ruby.git
cd ruby
```

### 2. Start the Development Environment
```bash
./start-dev.sh
```

That's it! The script handles everything automatically.

## Manual Setup (if start-dev.sh doesn't work)

### 1. Copy Environment File
```bash
cp .env.example .env
```

### 2. Start Docker Containers
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### 3. Set Up Database (first time only)
```bash
# Wait 10 seconds for PostgreSQL to be ready
sleep 10

# Create and set up database
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:create
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:migrate
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:seed
```

## Access the Application

- **URL**: http://localhost:3005
- **Admin Login**: 
  - Email: `admin@leclub.com`
  - Password: `password123`

## Daily Development Commands

### Start Development
```bash
cd ruby
docker-compose -f docker-compose.dev.yml up -d
```

### Stop Development
```bash
docker-compose -f docker-compose.dev.yml down
```

### View Logs
```bash
docker-compose -f docker-compose.dev.yml logs -f leclub_web_dev
```

### Rails Console
```bash
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails console
```

### Run Migrations
```bash
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:migrate
```

## Making Changes

1. **Edit files locally** - Changes appear instantly
2. **Add images** to `app/assets/images/` - Available immediately
3. **Modify views/controllers** - Rails auto-reloads
4. **Change Gemfile** - Run:
   ```bash
   docker-compose -f docker-compose.dev.yml exec leclub_web_dev bundle install
   docker-compose -f docker-compose.dev.yml restart leclub_web_dev
   ```

## Syncing Work Between Computers

### Before Leaving Computer A:
```bash
git add .
git commit -m "Work in progress"
git push origin main
```

### On Computer B:
```bash
git pull origin main
docker-compose -f docker-compose.dev.yml restart leclub_web_dev
```

## Troubleshooting

### Port 3005 Already in Use
Change the port in `docker-compose.dev.yml`:
```yaml
ports:
  - "3006:3000"  # Change to any free port
```

### Container Won't Start
```bash
# Clean restart
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d --build
```

### Database Issues
```bash
# Reset database completely
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:drop
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:create
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:migrate
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:seed
```

## Quick Reference

| Task | Command |
|------|---------|
| Start | `./start-dev.sh` |
| Stop | `docker-compose -f docker-compose.dev.yml down` |
| Logs | `docker-compose -f docker-compose.dev.yml logs -f` |
| Console | `docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails console` |
| Tests | `docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails test` |

## Remember

- **Everything is in Docker** - No need to install Ruby, Rails, PostgreSQL locally
- **Files sync automatically** - Edit locally, see changes immediately
- **Database persists** - Your data stays between restarts
- **Same on all computers** - Windows, Mac, Linux all work identically

---

Happy coding! 🚀