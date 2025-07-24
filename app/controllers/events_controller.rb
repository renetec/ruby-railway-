class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :rsvp, :cancel_rsvp, :dashboard]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :rsvp, :cancel_rsvp, :dashboard]
  before_action :authorize_event, only: [:edit, :update, :destroy, :dashboard]
  
  def index
    # Get all events for calendar view (unpaginated)
    @all_events = Event.published.includes(:user, :event_rsvps)
    
    # Get filtered events for list view (paginated)
    @events = Event.published
                   .includes(:user, :event_rsvps, images_attachments: :blob)
    
    @events = @events.upcoming if params[:filter] == 'upcoming'
    @events = @events.past if params[:filter] == 'past'
    @events = @events.by_category(params[:category]) if params[:category].present?
    @events = @events.by_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
    
    @events = @events.order(created_at: :desc).page(params[:page]).per(12)
    @categories = Event.categories.keys
  end
  
  def show
    @user_rsvp = current_user.event_rsvps.find_by(event: @event) if user_signed_in?
    @recent_attendees = @event.attendees.limit(10)
  end
  
  def new
    @event = current_user.events.build(status: :published)
  end
  
  def create
    @event = current_user.events.build(event_params)
    
    if @event.save
      redirect_to events_path, notice: t('flash.event_created_success')
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Event was successfully deleted.'
  end
  
  def rsvp
    if @event.can_rsvp?
      @rsvp = current_user.event_rsvps.build(event: @event)
      
      if @rsvp.save
        respond_to do |format|
          format.html { redirect_to @event, notice: 'Successfully RSVP\'d to event!' }
          format.json { render json: { success: true, message: 'Inscription confirmée!' } }
        end
      else
        respond_to do |format|
          format.html { redirect_to @event, alert: @rsvp.errors.full_messages.join(', ') }
          format.json { render json: { success: false, errors: @rsvp.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @event, alert: 'Cannot RSVP to this event.' }
        format.json { render json: { success: false, error: 'Cannot RSVP to this event.' }, status: :unprocessable_entity }
      end
    end
  end
  
  def cancel_rsvp
    @rsvp = current_user.event_rsvps.find_by(event: @event)
    
    if @rsvp&.destroy
      redirect_to @event, notice: 'RSVP cancelled successfully.'
    else
      redirect_to @event, alert: 'Could not cancel RSVP.'
    end
  end
  
  def dashboard
    @rsvps = @event.event_rsvps.includes(:user).confirmed
    @total_rsvps = @rsvps.count
    @capacity_percentage = @event.capacity.present? ? (@total_rsvps.to_f / @event.capacity * 100).round : nil
  end
  
  private
  
  def set_event
    @event = Event.friendly.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(:title, :description, :date, :location, :capacity, 
                                  :category, :status, :price, images: [])
  end
  
  def authorize_event
    redirect_to events_path, alert: 'Not authorized.' unless @event.user == current_user || current_user.moderator?
  end
end