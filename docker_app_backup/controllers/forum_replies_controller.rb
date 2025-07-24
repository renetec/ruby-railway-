class ForumRepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_forum_category
  before_action :set_forum_thread
  before_action :set_forum_reply, only: [:edit, :update, :destroy]
  before_action :authorize_forum_reply, only: [:edit, :update, :destroy]
  
  def create
    @forum_reply = @forum_thread.forum_replies.build(forum_reply_params)
    @forum_reply.user = current_user
    
    if @forum_reply.save
      redirect_to [@forum_category, @forum_thread], notice: 'Reply posted successfully!'
    else
      @forum_replies = @forum_thread.forum_replies
                                  .published
                                  .includes(:user)
                                  .chronological
                                  .page(params[:page]).per(20)
      render 'forum_threads/show', status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @forum_reply.update(forum_reply_params)
      redirect_to [@forum_category, @forum_thread], notice: 'Reply updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @forum_reply.destroy
    redirect_to [@forum_category, @forum_thread], notice: 'Reply deleted successfully.'
  end
  
  private
  
  def set_forum_category
    @forum_category = ForumCategory.friendly.find(params[:forum_category_id])
  end
  
  def set_forum_thread
    @forum_thread = @forum_category.forum_threads.friendly.find(params[:forum_thread_id])
  end
  
  def set_forum_reply
    @forum_reply = @forum_thread.forum_replies.find(params[:id])
  end
  
  def forum_reply_params
    params.require(:forum_reply).permit(:content, :parent_reply_id)
  end
  
  def authorize_forum_reply
    redirect_to [@forum_category, @forum_thread], alert: 'Not authorized.' unless @forum_reply.user == current_user || current_user.moderator?
  end
end