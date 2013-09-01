class CoursesController < ApplicationController
  before_filter :check_signed_in, only: [:new, :create, :update, :edit]
  before_filter :check_editing_own_course, only: [:update, :edit, :destroy]

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

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])

    if @course.update_attributes(course_params)
      flash[:success] = "Course #{@course.name} was updated successfully."
      redirect_to @course
    else
      render 'edit'
    end
  end

  def destroy
    course = Course.find(params[:id]).destroy
    flash[:success] = "Course #{course.name} was destroyed successfully."
    redirect_to root_path
  end

  def enroll
    @course = Course.find(params[:id])
    
    @course.students << current_user
    flash[:success] = "You have been enrolled into the course #{@course.name}"
    redirect_to @course
  end

  def analytics
    @course = Course.find(params[:id])
  end

  private

  def course_params
    params.require(:course).permit(:name, :description)
  end
end
