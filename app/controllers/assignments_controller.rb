class AssignmentsController < ApplicationController
  before_filter :change_due_time_param, only: [:update, :create]

  authorize_resource

  def show
    if signed_in?
      @user_submission = Submission.where(assignment: @assignment, author: current_user).first
    end
  end

  def new
    @course = @assignment.course # TODO: be able to not have to do this.
  end

  def create
    if @assignment.save
      @assignment.create_activity :create, owner: @assignment.course.teacher
      flash[:success] = "Assignment #{@assignment.name} created successfully."
      redirect_to @assignment.course
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @assignment.update_attributes(assignment_params)
      flash[:success] = "Assignment #{@assignment.name} updated successfully"
      redirect_to @assignment.course
    else
      render 'edit'
    end
  end

  def destroy
    assignment = @assignment.destroy
    flash[:success] = "Assignment #{assignment.name} was destroyed successfully."
    redirect_to assignment.course
  end

  def plagiarism
  end

  def compare
    @submission_a = Submission.find(params[:submission_a])
    @submission_b = Submission.find(params[:submission_b])

    if @submission_a.assignment != @assignment || @submission_b.assignment != @assignment
      flash[:error] = "This submission is not for that assignment."
      redirect_to root_path
    end
  end

  load_resources do
    before(:show, :edit, :update, :destroy, :plagiarism, :compare) do
      @assignment = Assignment.find(params[:id])
    end

    before(:new) do
      @course = Course.find(params[:course_id])
      @assignment = @course.assignments.new
    end

    before(:create) do
      @course = Course.find(params[:course_id])
      @assignment = @course.assignments.build(assignment_params)
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit(:name, :description, :due_time, :point_value,
      :expected_output, :input, :course_id)
  end

  def change_due_time_param
    due_time = params[:assignment][:due_time]

    begin
      params[:assignment][:due_time] = convert_string_to_date(due_time)
    rescue ArgumentError
      params[:assignment][:due_time] = nil
    end
  end

  def convert_string_to_date(due_time)
    if due_time
      Date.strptime(due_time, "%m/%d/%Y")
    end
  end
end
