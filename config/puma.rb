# Puma configuration file

# Specifies the number of `workers` to boot in clustered mode.
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Specifies the number of `threads` to use.
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Preload the application before forking worker processes
preload_app!