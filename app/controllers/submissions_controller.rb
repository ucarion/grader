class SubmissionsController < ApplicationController
  before_filter :check_signed_in, only: [:new, :create]
  before_filter :check_assignment_still_open, only: [:new, :create]
  before_filter :check_enrolled_in_corresponding_course, only: [:new, :create]

  def show
    @submission = Submission.find(params[:id])
  end

  def new
    @assignment = Assignment.find(params[:assignment_id])
    @submission = Submission.new
  end

  def create
    @assignment = Assignment.find(params[:assignment_id])
    @submission = @assignment.submissions.build(submission_params)

    if @submission.save
      flash[:success] = "Your submission was created successfully."
      redirect_to @submission
    else
      render 'new'
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:source_code, :author_id)
  end

  def check_assignment_still_open
    assignment = Assignment.find(params[:assignment_id])
    redirect_to root_path, notice: "This assignment is now closed." unless assignment.open?
  end

  def check_enrolled_in_corresponding_course
    assignment = Assignment.find(params[:assignment_id])

    unless assignment.course.students.exists?(current_user)
      redirect_to root_path, notice: "You cannot post submissions for this course"
    end
  end
end
