class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include PublicActivity::StoreController

  rescue_from Candela::AccessDeniedError do |error|
    flash[:error] = "You are not allowed to complete this action."
    redirect_to root_path
  end
end
