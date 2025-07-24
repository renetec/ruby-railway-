class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  def index
    @users = User.order(created_at: :desc).page(params[:page]).per(20)
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User updated successfully.'
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User deleted successfully.'
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :role, :status)
  end
end