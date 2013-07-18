class UsersController < ApplicationController
  before_filter :checked_signed_in, only: [:edit, :update]
  before_filter :check_right_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "Welcome, #{@user.name}!"
      sign_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      flash[:success] = "Successfully updated your account information."
      sign_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def checked_signed_in
    redirect_to signin_path, notice: "Sign in before completing this action." unless signed_in?
  end

  def check_right_user
    @user = User.find(params[:id])
    redirect_to root_path, notice: "You cannot edit others' information." unless current_user?(@user)
  end
end
