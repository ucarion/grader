class SubmissionsController < ApplicationController
  before_filter :check_signed_in, only: [:show, :new, :create]
  before_filter :check_assignment_still_open, only: [:new, :create]
  before_filter :check_enrolled_in_corresponding_course, only: [:new, :create]
  before_filter :check_is_own_submission_or_is_teacher, only: [:show]
  before_filter :check_is_teacher, only: [:grade]
  before_filter :check_is_teacher_for_index, only: [:index]

  def show
    @submission = Submission.find(params[:id])

    @comment = @submission.comments.build
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

  def index
    @assignment = Assignment.find(params[:assignment_id])
  end

  def grade
    @submission = Submission.find(params[:id])

    if @submission.update_attributes(submission_grading_params)
      flash[:success] = "The submission was updated successfully."
      redirect_to @submission
    else
      redirect_to @submission, flash: { error: submission_error_message }
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:source_code, :author_id)
  end

  def submission_grading_params
    params.require(:submission).permit(:grade)
  end

  # only show the first one, because otherwise it looks weird in an alert
  def submission_error_message
    "Error with your update: #{@submission.errors.full_messages.first}"
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

  def check_is_own_submission_or_is_teacher
    submission = Submission.find(params[:id])

    unless current_user?(submission.author) || current_user?(submission.assignment.course.teacher)
      redirect_to root_path, notice: "You cannot view others' submissions" 
    end
  end

  def check_is_teacher
    submission = Submission.find(params[:id])
    teacher = submission.assignment.course.teacher
    redirect_to root_path, notice: "You cannot grade this assignment." unless current_user?(teacher)
  end

  def check_is_teacher_for_index
    assignment = Assignment.find(params[:assignment_id])
    teacher = assignment.course.teacher

    redirect_to root_path, notice: "You cannot view this page" unless current_user?(teacher)
  end
end
