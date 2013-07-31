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
end
