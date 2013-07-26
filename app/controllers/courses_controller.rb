class CoursesController < ApplicationController
  before_filter :check_signed_in, only: [:new, :create]

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

  def enroll
    @course = Course.find(params[:id])
    
    @course.students << current_user
    flash[:success] = "You have been enrolled into the course #{@course.name}"
    redirect_to @course
  end

  private

  def course_params
    params.require(:course).permit(:name, :description)
  end
end
