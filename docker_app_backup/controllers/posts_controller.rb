class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_post, only: [:edit, :update, :destroy]
  
  def index
    @posts = Post.published
                 .includes(:user, images_attachments: :blob)
                 .recent
    
    @posts = @posts.by_category(params[:category]) if params[:category].present?
    @posts = @posts.where("title ILIKE ? OR content ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    
    @posts = @posts.page(params[:page]).per(12)
    @categories = Post::CATEGORIES
  end
  
  def show
    @related_posts = Post.published
                         .where.not(id: @post.id)
                         .by_category(@post.category)
                         .limit(3)
  end
  
  def new
    @post = current_user.posts.build
  end
  
  def create
    @post = current_user.posts.build(post_params)
    
    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Post was successfully deleted.'
  end
  
  private
  
  def set_post
    @post = Post.friendly.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:title, :content, :category, :status, :featured, images: [])
  end
  
  def authorize_post
    redirect_to posts_path, alert: 'Not authorized.' unless @post.user == current_user || current_user.moderator?
  end
end