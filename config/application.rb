require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Leclub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # Add services directory to autoload path
    config.autoload_paths << Rails.root.join("app", "services")

    # Permitted locales available for the application
    config.i18n.available_locales = [:fr, :en]
    config.i18n.default_locale = :fr

    # Allow Active Storage to accept uploads from all hosts
    config.active_storage.variant_processor = :mini_magick

    # Background job adapter
    config.active_job.queue_adapter = :sidekiq

    # Allow Action Cable connections from Docker
    config.action_cable.allowed_request_origins = ['http://localhost:3000', 'http://127.0.0.1:3000']
  end
end