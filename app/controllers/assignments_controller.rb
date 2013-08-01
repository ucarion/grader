class AssignmentsController < ApplicationController
  before_filter :check_signed_in, only: [:new, :create, :update, :edit]
  before_filter :check_editing_own_assignment, only: [:update, :edit]

  def show
    @assignment = Assignment.find(params[:id])
  end

  def new
    @course = Course.find(params[:course_id])
    @assignment = Assignment.new
  end

  def create
    change_due_time_param

    @course = Course.find(params[:course_id])
    @assignment = @course.assignments.build(assignment_params)

    if @assignment.save
      flash[:success] = "Assignment #{@assignment.name} created successfully."
      redirect_to @assignment.course
    else
      render 'new'
    end
  end

  def edit
    @assignment = Assignment.find(params[:id])
  end

  def update
    @assignment = Assignment.find(params[:id])

    change_due_time_param

    if @assignment.update_attributes(assignment_params)
      flash[:success] = "Assignment #{@assignment.name} updated successfully"
      redirect_to @assignment.course
    else
      render 'edit'
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit(:name, :description, :due_time)
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
