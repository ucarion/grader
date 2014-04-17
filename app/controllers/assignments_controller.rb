class AssignmentsController < ApplicationController
  before_filter :change_due_time_param, only: [:update, :create]

  def show
    @assignment = Assignment.find(params[:id])
    authorize @assignment

    if signed_in?
      @user_submission = Submission.where(assignment: @assignment, author: current_user).first
    end
  end

  def new
    @course = Course.find(params[:course_id])
    @assignment = @course.assignments.new

    authorize @assignment
  end

  def create
    @course = Course.find(params[:course_id])
    @assignment = @course.assignments.build(assignment_params)

    authorize @assignment

    if @assignment.save
      @assignment.create_activities
      flash[:success] = "Assignment #{@assignment.name} created successfully."
      redirect_to @assignment.course
    else
      render 'new'
    end
  end

  def edit
    @assignment = Assignment.find(params[:id])
    authorize @assignment
  end

  def update
    @assignment = Assignment.find(params[:id])
    authorize @assignment

    if @assignment.update_attributes(assignment_params)
      flash[:success] = "Assignment #{@assignment.name} updated successfully"
      redirect_to @assignment
    else
      render 'edit'
    end
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    authorize @assignment

    assignment = @assignment.destroy
    flash[:success] = "Assignment #{assignment.name} was destroyed successfully."
    redirect_to assignment.course
  end

  def plagiarism
    @assignment = Assignment.find(params[:id])

    authorize @assignment
  end

  def compare
    @assignment = Assignment.find(params[:id])
    authorize @assignment

    @submission_a = Submission.find(params[:submission_a])
    @submission_b = Submission.find(params[:submission_b])

    if @submission_a.assignment != @assignment || @submission_b.assignment != @assignment
      flash[:danger] = "This submission is not for that assignment."
      redirect_to root_path
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit(:name, :description, :due_time,
      :point_value, :should_run_tests, :expected_output, :input, :course_id,
      :max_attempts, :grace_period)
  end

  def change_due_time_param
    due_time = params[:assignment][:due_time]

    begin
      date_param = convert_string_to_date(due_time)

      # We add just under a day to make this due date be *inclusive*.
      params[:assignment][:due_time] = date_param + 1.day - 1.second
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
