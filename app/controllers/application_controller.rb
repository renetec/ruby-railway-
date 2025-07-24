class ApplicationController < ActionController::Base
  # Force Railway redeploy - nixpacks final attempt
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :authenticate_user!, unless: :devise_controller?, except: [:health]
  before_action :configure_permitted_parameters, if: :devise_controller?

  def health
    render json: { status: 'ok', timestamp: Time.current.iso8601 }
  end

  protected

  def authenticate_user!
    if !user_signed_in? && request.format.json?
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
    else
      super
    end
  end

  private

  def set_locale
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = I18n.locale
  end
  
  def default_url_options
    { locale: I18n.locale }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :avatar_preset])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :avatar_preset])
  end
end