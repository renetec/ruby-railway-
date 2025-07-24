class Admin::PostsController < AdminController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  def index
    @posts = Post.includes(:user).order(created_at: :desc).page(params[:page]).per(20)
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: 'Post updated successfully.'
    else
      render :edit
    end
  end
  
  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: 'Post deleted successfully.'
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:title, :content, :status, :featured, :category)
  end
end