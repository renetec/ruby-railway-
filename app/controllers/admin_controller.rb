class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def index
    # Redirect to the actual Avo admin interface
    redirect_to '/avo'
  end

  private

  def ensure_admin!
    unless current_user.admin?
      flash[:alert] = t('flash.access_denied_admin')
      redirect_to root_path
    end
  end
end