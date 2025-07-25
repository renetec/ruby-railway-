require "rspec/rails"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

RSpec.configure do  < /dev/null | config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
end
