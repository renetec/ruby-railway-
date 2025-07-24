class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :apply]
  before_action :authorize_job, only: [:edit, :update, :destroy]
  
  def index
    @jobs = Job.active
               .includes(:business, :job_applications)
               .recent
    
    # Filtering
    @jobs = @jobs.by_job_type(params[:job_type]) if params[:job_type].present?
    @jobs = @jobs.by_experience_level(params[:experience_level]) if params[:experience_level].present?
    @jobs = @jobs.by_location(params[:location]) if params[:location].present?
    @jobs = @jobs.search_by_term(params[:search]) if params[:search].present?
    @jobs = @jobs.remote if params[:remote] == 'true'
    @jobs = @jobs.with_salary if params[:with_salary] == 'true'
    @jobs = @jobs.urgent if params[:urgent] == 'true'
    @jobs = @jobs.featured if params[:featured] == 'true'
    
    @jobs = @jobs.page(params[:page]).per(15)
    
    # Filter options
    @job_types = Job.job_types.keys
    @experience_levels = Job.experience_levels.keys
    @locations = Job.active.distinct.pluck(:location).compact.sort
  end
  
  def show
    @application = current_user&.job_applications&.find_by(job: @job)
    @related_jobs = Job.active
                       .joins(:business)
                       .where(businesses: { category: @job.business.category })
                       .where.not(id: @job.id)
                       .limit(5)
  end
  
  def new
    @business = current_user.businesses.find(params[:business_id]) if params[:business_id]
    @job = (@business || current_user.businesses.first)&.jobs&.build
    
    redirect_to new_business_path, alert: 'Please create a business profile first.' unless @job
  end
  
  def create
    @business = current_user.businesses.find(params[:job][:business_id])
    @job = @business.jobs.build(job_params)
    
    if @job.save
      redirect_to @job, notice: 'Job posting created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @job.update(job_params)
      redirect_to @job, notice: 'Job posting updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @job.destroy
    redirect_to jobs_path, notice: 'Job posting deleted successfully.'
  end
  
  def apply
    if @job.can_apply? && current_user
      @application = current_user.job_applications.build(job: @job)
      
      if @application.save
        redirect_to @job, notice: 'Application submitted successfully!'
      else
        redirect_to @job, alert: @application.errors.full_messages.join(', ')
      end
    else
      redirect_to @job, alert: 'Cannot apply to this job.'
    end
  end
  
  def my_jobs
    @jobs = current_user.businesses
                       .joins(:jobs)
                       .merge(Job.includes(:job_applications))
                       .page(params[:page]).per(15)
  end
  
  def my_applications
    @applications = current_user.job_applications
                               .includes(:job, job: :business)
                               .recent
                               .page(params[:page]).per(15)
  end
  
  private
  
  def set_job
    @job = Job.friendly.find(params[:id])
  end
  
  def job_params
    params.require(:job).permit(:title, :description, :job_type, :experience_level,
                               :location, :remote, :salary_min, :salary_max,
                               :application_deadline, :requirements, :benefits,
                               :status, :urgent, :featured, :business_id)
  end
  
  def authorize_job
    redirect_to jobs_path, alert: 'Not authorized.' unless @job.business.user == current_user || current_user.moderator?
  end
end