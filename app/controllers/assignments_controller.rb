class AssignmentsController < ApplicationController
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

  private

  def assignment_params
    params.require(:assignment).permit(:name, :description)
  end
end
