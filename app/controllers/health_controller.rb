class HealthController < ActionController::Base
  skip_before_action :verify_authenticity_token
  
  def show
    render json: { status: 'ok', timestamp: Time.current.iso8601, rails_env: Rails.env }, status: :ok
  end
end