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

  load_resources do
    before(:show, :edit, :update) do
      @user = User.find(params[:id])
    end

    before(:new) do
      @user = User.new
    end

    before(:create) do
      @user = User.new(user_params)
    end

    before(:destroy) do
      @user = User.find(params[:id])
    end

    before(:index) do
      @users = User.all
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
