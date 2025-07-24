class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :mark_sold]
  before_action :authorize_product, only: [:edit, :update, :destroy, :mark_sold]
  
  def index
    @products = Product.active
                       .includes(:user, images_attachments: :blob)
                       .recent
    
    # Filtering
    @products = @products.by_category(params[:category]) if params[:category].present?
    @products = @products.by_condition(params[:condition]) if params[:condition].present?
    @products = @products.by_location(params[:location]) if params[:location].present?
    @products = @products.search_by_term(params[:search]) if params[:search].present?
    
    # Price range filtering
    if params[:min_price].present? && params[:max_price].present?
      @products = @products.by_price_range(params[:min_price], params[:max_price])
    end
    
    @products = @products.page(params[:page]).per(12)
    
    # Filter options for sidebar
    @categories = Product::CATEGORIES
    @conditions = Product.conditions.keys
    @price_ranges = [
      { label: "Under $25", min: 0, max: 25 },
      { label: "$25 - $50", min: 25, max: 50 },
      { label: "$50 - $100", min: 50, max: 100 },
      { label: "$100 - $250", min: 100, max: 250 },
      { label: "$250+", min: 250, max: 999999 }
    ]
  end
  
  def show
    @related_products = Product.active
                               .where.not(id: @product.id)
                               .by_category(@product.category)
                               .limit(4)
  end
  
  def new
    @product = current_user.products.build
  end
  
  def create
    @product = current_user.products.build(product_params)
    
    if @product.save
      redirect_to @product, notice: 'Product listing created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product listing updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Product listing deleted successfully.'
  end
  
  def mark_sold
    if @product.mark_as_sold!
      redirect_to @product, notice: 'Product marked as sold!'
    else
      redirect_to @product, alert: 'Could not mark product as sold.'
    end
  end
  
  def my_products
    @products = current_user.products
                           .includes(images_attachments: :blob)
                           .recent
                           .page(params[:page]).per(12)
  end
  
  private
  
  def set_product
    @product = Product.friendly.find(params[:id])
  end
  
  def product_params
    params.require(:product).permit(:name, :description, :price, :category, 
                                   :condition, :location, :status, :featured, 
                                   images: [])
  end
  
  def authorize_product
    redirect_to products_path, alert: 'Not authorized.' unless @product.user == current_user || current_user.moderator?
  end
end