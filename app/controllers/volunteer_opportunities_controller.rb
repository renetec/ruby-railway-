class VolunteerOpportunitiesController < ApplicationController
  before_action :set_volunteer_opportunity, only: [:show, :edit, :update, :destroy, :apply]
  before_action :authorize_volunteer_opportunity, only: [:edit, :update, :destroy]
  
  def index
    @volunteer_opportunities = VolunteerOpportunity.active
                                                  .includes(:user, :volunteer_applications)
                                                  .recent
    
    # Filtering
    @volunteer_opportunities = @volunteer_opportunities.by_category(params[:category]) if params[:category].present?
    @volunteer_opportunities = @volunteer_opportunities.by_time_commitment(params[:time_commitment]) if params[:time_commitment].present?
    @volunteer_opportunities = @volunteer_opportunities.by_location(params[:location]) if params[:location].present?
    @volunteer_opportunities = @volunteer_opportunities.search_by_term(params[:search]) if params[:search].present?
    @volunteer_opportunities = @volunteer_opportunities.remote if params[:remote] == 'true'
    @volunteer_opportunities = @volunteer_opportunities.urgent if params[:urgent] == 'true'
    @volunteer_opportunities = @volunteer_opportunities.featured if params[:featured] == 'true'
    
    @volunteer_opportunities = @volunteer_opportunities.page(params[:page]).per(12)
    
    # Filter options
    @categories = VolunteerOpportunity::CATEGORIES
    @time_commitments = VolunteerOpportunity.time_commitments.keys
    @locations = VolunteerOpportunity.active.distinct.pluck(:location).compact.sort
  end
  
  def show
    @application = current_user&.volunteer_applications&.find_by(volunteer_opportunity: @volunteer_opportunity)
    @related_opportunities = VolunteerOpportunity.active
                                                .where.not(id: @volunteer_opportunity.id)
                                                .by_category(@volunteer_opportunity.category)
                                                .limit(4)
  end
  
  def new
    @volunteer_opportunity = current_user.volunteer_opportunities.build
  end
  
  def create
    @volunteer_opportunity = current_user.volunteer_opportunities.build(volunteer_opportunity_params)
    
    if @volunteer_opportunity.save
      redirect_to @volunteer_opportunity, notice: 'Volunteer opportunity created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @volunteer_opportunity.update(volunteer_opportunity_params)
      redirect_to @volunteer_opportunity, notice: 'Volunteer opportunity updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @volunteer_opportunity.destroy
    redirect_to volunteer_opportunities_path, notice: 'Volunteer opportunity deleted successfully.'
  end
  
  def apply
    if @volunteer_opportunity.can_apply? && current_user
      @application = current_user.volunteer_applications.build(volunteer_opportunity: @volunteer_opportunity)
      
      if @application.save
        redirect_to @volunteer_opportunity, notice: 'Application submitted successfully!'
      else
        redirect_to @volunteer_opportunity, alert: @application.errors.full_messages.join(', ')
      end
    else
      redirect_to @volunteer_opportunity, alert: 'Cannot apply to this opportunity.'
    end
  end
  
  def my_opportunities
    @volunteer_opportunities = current_user.volunteer_opportunities
                                          .includes(:volunteer_applications)
                                          .recent
                                          .page(params[:page]).per(12)
  end
  
  def my_applications
    @applications = current_user.volunteer_applications
                               .includes(:volunteer_opportunity)
                               .recent
                               .page(params[:page]).per(12)
  end
  
  private
  
  def set_volunteer_opportunity
    @volunteer_opportunity = VolunteerOpportunity.friendly.find(params[:id])
  end
  
  def volunteer_opportunity_params
    params.require(:volunteer_opportunity).permit(:title, :description, :category,
                                                 :time_commitment, :location, :remote,
                                                 :start_date, :end_date, :volunteers_needed,
                                                 :requirements, :status, :urgent, :featured,
                                                 :organization_id, :application_deadline)
  end
  
  def authorize_volunteer_opportunity
    redirect_to volunteer_opportunities_path, alert: 'Not authorized.' unless @volunteer_opportunity.user == current_user || current_user.moderator?
  end
end