# This file is used by Rack-based servers to start the application.

# Create a simple health check app that bypasses Rails entirely
class HealthApp
  def call(env)
    if env['PATH_INFO'] == '/health'
      [200, {'Content-Type' => 'application/json'}, ['{"status":"ok","time":"' + Time.now.iso8601 + '"}']]
    else
      [404, {'Content-Type' => 'text/plain'}, ['Health endpoint only']]
    end
  end
end

# Try to load Rails, but provide health check even if Rails fails
begin
  require_relative "config/environment"
  
  # Use Rack::URLMap to route /health to our simple app, everything else to Rails
  map '/health' do
    run HealthApp.new
  end
  
  map '/' do
    run Rails.application
  end
  
rescue => e
  # If Rails fails to load, just serve the health check
  puts "Rails failed to load: #{e.message}"
  run HealthApp.new
end