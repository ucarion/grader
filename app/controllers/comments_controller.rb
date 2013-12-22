class CommentsController < ApplicationController
  before_filter :check_signed_in, only: [:create]
  before_filter :check_teacher_or_student, only: [:create]

  def create
    @comment = current_user.comments.build(comment_params)
    authorize @comment

    if @comment.save
      @comment.create_activity :create, owner: @comment.user
      flash[:success] = "Comment created."
      redirect_to @comment.submission
    else
      redirect_to @comment.submission, flash: { error: comment_error }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :submission_id)
  end

  def comment_error
    "There was an error with your comment: #{@comment.errors.full_messages.first}"
  end

  def check_teacher_or_student
    submission = Submission.find(params[:comment][:submission_id])
    course = submission.assignment.course
    
    unless current_user?(course.teacher) || course.students.include?(current_user)
      redirect_to root_path, notice: "You cannot comment on this submission!"
    end
  end
end
