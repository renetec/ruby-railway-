class ForumThreadsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_forum_category
  before_action :set_forum_thread, only: [:show, :edit, :update, :destroy, :lock, :unlock, :pin, :unpin]
  before_action :authorize_forum_thread, only: [:edit, :update, :destroy]
  before_action :authorize_moderator, only: [:lock, :unlock, :pin, :unpin]
  
  def show
    @forum_replies = @forum_thread.forum_replies
                                 .published
                                 .includes(:user)
                                 .chronological
                                 .page(params[:page]).per(20)
    
    @forum_reply = ForumReply.new
  end
  
  def new
    @forum_thread = @forum_category.forum_threads.build
  end
  
  def create
    @forum_thread = @forum_category.forum_threads.build(forum_thread_params)
    @forum_thread.user = current_user
    
    if @forum_thread.save
      redirect_to [@forum_category, @forum_thread], notice: 'Thread created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @forum_thread.update(forum_thread_params)
      redirect_to [@forum_category, @forum_thread], notice: 'Thread updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @forum_thread.destroy
    redirect_to @forum_category, notice: 'Thread deleted successfully.'
  end
  
  def lock
    @forum_thread.update(locked: true)
    redirect_to [@forum_category, @forum_thread], notice: 'Thread locked.'
  end
  
  def unlock
    @forum_thread.update(locked: false)
    redirect_to [@forum_category, @forum_thread], notice: 'Thread unlocked.'
  end
  
  def pin
    @forum_thread.update(pinned: true)
    redirect_to [@forum_category, @forum_thread], notice: 'Thread pinned.'
  end
  
  def unpin
    @forum_thread.update(pinned: false)
    redirect_to [@forum_category, @forum_thread], notice: 'Thread unpinned.'
  end
  
  private
  
  def set_forum_category
    @forum_category = ForumCategory.friendly.find(params[:forum_category_id])
  end
  
  def set_forum_thread
    @forum_thread = @forum_category.forum_threads.friendly.find(params[:id])
  end
  
  def forum_thread_params
    params.require(:forum_thread).permit(:title, :content, :status)
  end
  
  def authorize_forum_thread
    redirect_to @forum_category, alert: 'Not authorized.' unless @forum_thread.user == current_user || current_user.moderator?
  end
  
  def authorize_moderator
    redirect_to @forum_category, alert: 'Not authorized.' unless current_user.moderator?
  end
end