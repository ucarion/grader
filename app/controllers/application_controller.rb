class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit

  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Make sure Pundit is always used, except on the static pages
  after_filter :verify_authorized,
    :except => [:index, :search, :try_enroll],
    unless: :devise_controller?

  after_filter :verify_policy_scoped,
    :only => [:index],
    unless: :devise_controller?

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    flash[:danger] = "You are not allowed to complete this action."
    redirect_to root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
  end
end
