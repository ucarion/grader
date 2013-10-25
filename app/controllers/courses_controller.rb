class CoursesController < ApplicationController
  authorize_resource

  def show
  end

  def new
  end

  def create
    if @course.save
      flash[:success] = "Course #{@course.name} created successfully!"
      redirect_to @course
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @course.update_attributes(course_params)
      flash[:success] = "Course #{@course.name} was updated successfully."
      redirect_to @course
    else
      render 'edit'
    end
  end

  def destroy
    course = @course.destroy
    flash[:success] = "Course #{course.name} was destroyed successfully."
    redirect_to root_path
  end

  def enroll
    @course.students << current_user
    flash[:success] = "You have been enrolled into the course #{@course.name}"
    redirect_to @course
  end

  def analytics
  end

  load_resources do
    before(:show, :edit, :update, :destroy, :enroll, :analytics) do
      @course = Course.find(params[:id])
    end

    before(:new) do
      @course = Course.new
    end

    before(:create) do
      @course = current_user.taught_courses.build(course_params)
    end
  end

  private

  def course_params
    params.require(:course).permit(:name, :description, :language)
  end
end
