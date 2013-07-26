class CoursesController < ApplicationController
  def show
    @course = Course.find(params[:id])
  end

  def new
    @course = Course.new
  end

  def create
    @course = current_user.taught_courses.build(course_params)
    if @course.save
      flash[:success] = "Course #{@course.name} created successfully!"
      redirect_to @course
    else
      render 'new'
    end
  end

  private

  def course_params
    params.require(:course).permit(:name, :description)
  end
end
