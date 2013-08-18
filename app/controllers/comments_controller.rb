class CommentsController < ApplicationController
  def create
    @comment = current_user.comments.build(comment_params)

    if @comment.save
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
end
