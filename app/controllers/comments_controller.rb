class CommentsController < ApplicationController
  def create
    @comment = current_user.comments.build(comment_params)
    authorize @comment

    if @comment.save
      @comment.handle_create!

      flash[:success] = "Comment created."
      redirect_to @comment.submission
    else
      redirect_to @comment.submission, flash: { danger: comment_error }
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

    unless current_user == course.teacher || course.students.include?(current_user)
      redirect_to root_path, notice: "You cannot comment on this submission!"
    end
  end
end
