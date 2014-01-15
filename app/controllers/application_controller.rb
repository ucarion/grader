class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include PublicActivity::StoreController
  include Pundit

  # Make sure Pundit is always used, except on the static pages
  after_filter :verify_authorized, :except => :index
  after_filter :verify_policy_scoped, :only => :index

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:danger] = "You are not allowed to complete this action."
    redirect_to root_path
  end
end
