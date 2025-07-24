class ForumCategoriesController < ApplicationController
  before_action :set_forum_category, only: [:show]
  
  def index
    @forum_categories = ForumCategory.visible
                                   .includes(:forum_threads)
                                   .ordered
    
    @recent_threads = ForumThread.published
                                .includes(:user, :forum_category)
                                .recent
                                .limit(10)
  end
  
  def show
    @forum_threads = @forum_category.forum_threads
                                  .published
                                  .includes(:user, :forum_replies)
                                  .recent
                                  .page(params[:page]).per(15)
  end
  
  private
  
  def set_forum_category
    @forum_category = ForumCategory.friendly.find(params[:id])
  end
end