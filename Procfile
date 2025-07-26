release: bundle exec rails db:migrate RAILS_ENV=production && bundle exec rails assets:precompile RAILS_ENV=production
web: bundle exec rails db:migrate && bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
health: ruby health_server.rb