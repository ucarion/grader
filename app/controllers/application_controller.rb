class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include PublicActivity::StoreController
  include Pundit

  # Make sure Pundit is always used, except on the static pages
  after_filter :verify_authorized, :except => :index
  after_filter :verify_policy_scoped, :only => :index
end
