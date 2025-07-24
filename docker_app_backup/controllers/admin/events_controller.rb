class Admin::EventsController < AdminController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  
  def index
    @events = Event.includes(:user).order(created_at: :desc).page(params[:page]).per(20)
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: 'Event updated successfully.'
    else
      render :edit
    end
  end
  
  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: 'Event deleted successfully.'
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(:title, :description, :status, :category, :location, :start_date, :end_date)
  end
end