class StaticPagesController < ApplicationController
  def home
    authorize self

    if signed_in?
      render 'user_home'
    else
      render 'guest_home'
    end
  end

  def help
    authorize self
  end

  def about
    authorize self
  end
end
