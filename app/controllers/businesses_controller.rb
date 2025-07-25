class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]
  before_action :authorize_business, only: [:edit, :update, :destroy]
  
  def index
    @businesses = Business.active
                         .includes(:user, :jobs, logo_attachment: :blob)
                         .alphabetical
    
    # Filtering
    @businesses = @businesses.by_category(params[:category]) if params[:category].present?
    @businesses = @businesses.by_location(params[:location]) if params[:location].present?
    @businesses = @businesses.search_by_term(params[:search]) if params[:search].present?
    @businesses = @businesses.featured if params[:featured] == 'true'
    @businesses = @businesses.with_jobs if params[:with_jobs] == 'true'
    
    @businesses = @businesses.page(params[:page]).per(12)
    
    # Filter options
    @categories = Business::CATEGORIES
    @locations = Business.active.distinct.pluck(:city).compact.sort
  end
  
  def show
    @jobs = @business.jobs.active.recent.limit(5)
    @reviews = @business.business_reviews.includes(:user).recent.limit(10)
    @related_businesses = Business.active
                                 .where.not(id: @business.id)
                                 .by_category(@business.category)
                                 .limit(4)
  end
  
  def new
    @business = current_user.businesses.build
  end
  
  def create
    @business = current_user.businesses.build(business_params)
    
    if @business.save
      redirect_to @business, notice: 'Business listing created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @business.update(business_params)
      redirect_to @business, notice: 'Business listing updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @business.destroy
    redirect_to businesses_path, notice: 'Business listing deleted successfully.'
  end
  
  def my_businesses
    @businesses = current_user.businesses
                             .includes(:jobs, logo_attachment: :blob)
                             .recent
                             .page(params[:page]).per(12)
  end
  
  private
  
  def set_business
    @business = Business.friendly.find(params[:id])
  end
  
  def business_params
    params.require(:business).permit(:name, :description, :category, :address, 
                                    :city, :state, :zip_code, :phone, :email, 
                                    :website, :hours, :status, :featured, 
                                    :logo, images: [])
  end
  
  def authorize_business
    redirect_to businesses_path, alert: 'Not authorized.' unless @business.user == current_user || current_user.moderator?
  end
end