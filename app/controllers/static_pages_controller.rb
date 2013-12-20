class StaticPagesController < ApplicationController
  def home
    authorize self

    if signed_in?
      network = current_user.student_ids | current_user.teacher_ids

      @activities = PublicActivity::Activity.where(owner_id: network)
    end
  end

  def help
    authorize self
  end

  def about
    authorize self
  end
end
