class SubmissionsController < ApplicationController
  authorize_resource

  def show
    @comment = @submission.comments.build
  end

  def new
    @assignment = @submission.assignment
    @submission.source_files.build
  end

  def create
    if @submission.save
      @submission.create_activity :create, owner: @submission.author
      flash[:success] = "Your submission was created successfully."
      redirect_to @submission
      @submission.execute_code!
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @submission.update_attributes(submission_update_params)
      flash[:success] = "Your submission was successfully updated."
      redirect_to @submission
      @submission.init_status
      @submission.execute_code!
    else
      render 'edit'
    end
  end

  def index
    
  end

  def grade
    if @submission.update_attributes(submission_grading_params)
      flash[:success] = "The submission was updated successfully."
      redirect_to @submission
    else
      redirect_to @submission, flash: { error: submission_error_message }
    end
  end

  load_resources do
    before(:show, :edit, :update, :grade) do
      @submission = Submission.find(params[:id])
    end

    before(:new) do
      @assignment = Assignment.find(params[:assignment_id])
      @submission = @assignment.submissions.build
    end

    before(:create) do
      @assignment = Assignment.find(params[:assignment_id])
      @submission = Submission.new(submission_params)
    end

    before(:index) do
      @assignment = Assignment.find(params[:assignment_id])
      @submissions = @assignment.submissions
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:assignment_id, :author_id, 
      source_files_attributes: source_file_params)
  end

  def submission_grading_params
    params.require(:submission).permit(:grade)
  end

  def submission_update_params
    params.require(:submission).permit(source_files_attributes: source_file_params)
  end

  def source_file_params
    [ :code, :main, :id, :_destroy ]
  end

  # only show the first one, because otherwise it looks weird in an alert
  def submission_error_message
    "Error with your update: #{@submission.errors.full_messages.first}"
  end
end
