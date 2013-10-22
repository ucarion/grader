class AssignmentsController < ApplicationController
  before_filter :change_due_time_param, only: [:update, :create]

  authorize_resource parent: :course

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
