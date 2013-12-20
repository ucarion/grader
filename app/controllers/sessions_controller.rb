class SessionsController < ApplicationController
  def new
    authorize self
  end

  def create
    authorize self

    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      flash[:success] = "Welcome back, #{user.name}!"
      sign_in user
      redirect_to_return_or user
    else
      flash.now[:error] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    authorize self
    sign_out
    redirect_to root_path
  end
end
