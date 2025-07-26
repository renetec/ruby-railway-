release: bundle exec rails db:migrate && bundle exec rails assets:precompile
web: bundle exec puma -C config/puma.rb
health: ruby health_server.rb