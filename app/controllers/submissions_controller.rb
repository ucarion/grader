class SubmissionsController < ApplicationController
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
end
