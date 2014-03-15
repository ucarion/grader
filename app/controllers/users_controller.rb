class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

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
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update_attributes(user_params)
      flash[:success] = "Successfully updated your account information."
      sign_in @user
      redirect_to @user
    else
      render 'devise/registrations/edit'
    end
  end

  def index
    @users = policy_scope(User).paginate(page: params[:page])
  end

  def destroy
    @user = User.find(params[:id])
    authorize @user

    user = @user.destroy
    flash[:success] = "User #{user.name} was destroyed."
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation)
  end
end
