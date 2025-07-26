release: bundle exec rails db:migrate && bundle exec rails assets:precompile
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
health: ruby health_server.rb