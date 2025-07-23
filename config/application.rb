require_relative "boot"

require "rails"
# Skip ActiveRecord temporarily for Railway deployment
%w(
  active_model/railtie
  active_job/railtie
  action_controller/railtie
  action_mailer/railtie
  action_mailbox/engine
  action_text/engine
  action_view/railtie
  action_cable/engine
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

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