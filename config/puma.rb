# Puma configuration for Railway deployment

# The environment that the application will run in
environment ENV.fetch("RAILS_ENV", "production")

# Use the PORT environment variable provided by Railway
port ENV.fetch("PORT", 3000)

# Use IPv4 binding for Railway compatibility
bind "0.0.0.0:#{ENV.fetch('PORT', 3000)}"

# Number of worker processes (adjust based on Railway plan)
workers ENV.fetch("WEB_CONCURRENCY", 2)

# Number of threads per worker
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

# Disable preload to prevent Rails startup issues on Railway
# preload_app!

# Restart workers if they use too much memory
worker_timeout 30
worker_boot_timeout 30

# Allow Puma to be restarted by `rails restart` command
plugin :tmp_restart

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end