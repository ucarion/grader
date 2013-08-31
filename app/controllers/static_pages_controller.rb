class StaticPagesController < ApplicationController
  def home
    if signed_in?
      network = current_user.student_ids | current_user.teacher_ids

      @activities = PublicActivity::Activity.where(owner_id: network)
    end
  end

  def help
  end

  def about
  end
end
