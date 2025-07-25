# Cross-Platform Docker Development Setup

This setup works seamlessly on both Windows (WSL2) and Ubuntu systems.

## Quick Start (Same on Both Systems!)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/renetec/ruby.git
   cd ruby
   ```

2. **Start development environment:**
   ```bash
   ./start-dev.sh
   ```

That's it! The script automatically detects your OS and configures everything.

## Manual Start (if you prefer)

```bash
# Copy environment file
cp .env.example .env

# Start containers
docker-compose -f docker-compose.dev.yml up -d

# First time only - setup database
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:create
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:migrate
docker-compose -f docker-compose.dev.yml exec leclub_web_dev rails db:seed
```

## Access Your App
- URL: http://localhost:3005
- Admin: admin@leclub.com / password123

## Switching Between Windows and Ubuntu

The beauty of this setup:
1. **Same commands** work on both systems
2. **Git sync** your code changes
3. **Docker volumes** are isolated per machine
4. **No configuration changes** needed

### On Windows (WSL2):
```bash
# Make sure Docker Desktop is running
cd /path/to/ruby
./start-dev.sh
```

### On Ubuntu:
```bash
# Make sure Docker is installed
cd /path/to/ruby
./start-dev.sh
```

## File Editing

- **Windows**: Edit files using VS Code with WSL2 extension
- **Ubuntu**: Edit files with any editor

Changes are immediately reflected in the running container!

## Syncing Work Between Machines

1. **Before switching machines:**
   ```bash
   git add .
   git commit -m "Work in progress"
   git push origin main
   ```

2. **On the other machine:**
   ```bash
   git pull origin main
   ./start-dev.sh
   ```

## Tips

- Database is separate on each machine (use db:seed for consistent data)
- Gems are cached locally (faster starts after first run)
- Use the same Ruby version (3.2.8) on both systems
- The script handles OS-specific networking automatically

## Troubleshooting

**Windows WSL2 Issues:**
- Ensure Docker Desktop is set to use WSL2 backend
- Check WSL2 is updated: `wsl --update`

**Ubuntu Issues:**
- Ensure your user is in docker group: `sudo usermod -aG docker $USER`
- Logout and login again after adding to docker group

**Both Systems:**
- Port conflicts: Edit ports in docker-compose.dev.yml
- Clean restart: `docker-compose -f docker-compose.dev.yml down -v`