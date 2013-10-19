class UsersController < ApplicationController
  authorize_resource

  def show
  end

  def new
  end

  def create
    if @user.save
      flash[:success] = "Welcome, #{@user.name}!"
      sign_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Successfully updated your account information."
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    user = @user.destroy
    flash[:success] = "User #{user.name} was destroyed."
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
