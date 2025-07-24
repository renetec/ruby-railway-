class Admin::ForumCategoriesController < AdminController
  before_action :set_forum_category, only: [:show, :edit, :update, :destroy]
  
  def index
    @forum_categories = ForumCategory.order(:name).page(params[:page]).per(20)
  end
  
  def show
  end
  
  def new
    @forum_category = ForumCategory.new
  end
  
  def create
    @forum_category = ForumCategory.new(forum_category_params)
    
    if @forum_category.save
      redirect_to admin_forum_category_path(@forum_category), notice: 'Forum category created successfully.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @forum_category.update(forum_category_params)
      redirect_to admin_forum_category_path(@forum_category), notice: 'Forum category updated successfully.'
    else
      render :edit
    end
  end
  
  def destroy
    @forum_category.destroy
    redirect_to admin_forum_categories_path, notice: 'Forum category deleted successfully.'
  end
  
  private
  
  def set_forum_category
    @forum_category = ForumCategory.find(params[:id])
  end
  
  def forum_category_params
    params.require(:forum_category).permit(:name, :description, :color, :icon)
  end
end