class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :ensure_own_profile, only: [:edit, :update]

  def show
    @user_stats = {
      member_since: l(@user.created_at, format: :long),
      posts_count: @user.posts.published.count,
      events_count: @user.events.count
    }
    
    @recent_posts = @user.posts.published.order(created_at: :desc).limit(5)
    @recent_events = @user.events.order(date: :desc).limit(5)
  end

  def edit
    # Profile editing view
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path(@user), notice: t('users.profile_updated_successfully') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def posts
    @posts = @user.posts.published.order(created_at: :desc).page(params[:page]).per(10)
  end

  def events
    @events = @user.events.order(date: :desc).page(params[:page]).per(10)
  end

  def forum_activity
    @forum_threads = @user.forum_threads.order(created_at: :desc).limit(10)
    @forum_replies = @user.forum_replies.order(created_at: :desc).limit(10)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_own_profile
    redirect_to user_path(@user), alert: t('users.unauthorized_access') unless @user == current_user
  end

  def user_params
    params.require(:user).permit(:name, :nickname, :avatar, :avatar_preset)
  end
end