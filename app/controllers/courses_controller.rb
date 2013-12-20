class CoursesController < ApplicationController
  def show
    @course = Course.find(params[:id])
    authorize @course
  end

  def new
    @course = Course.new
    authorize @course
  end

  def create
    @course = current_user.taught_courses.build(course_params)
    authorize @course

    if @course.save
      flash[:success] = "Course #{@course.name} created successfully!"
      redirect_to @course
    else
      render 'new'
    end
  end

  def edit
    @course = Course.find(params[:id])
    authorize @course
  end

  def update
    @course = Course.find(params[:id])
    authorize @course

    if @course.update_attributes(course_params)
      flash[:success] = "Course #{@course.name} was updated successfully."
      redirect_to @course
    else
      render 'edit'
    end
  end

  def destroy
    @course = Course.find(params[:id])
    authorize @course

    course = @course.destroy
    flash[:success] = "Course #{course.name} was destroyed successfully."
    redirect_to root_path
  end

  def enroll
    @course = Course.find(params[:id])
    authorize @course

    @course.students << current_user
    flash[:success] = "You have been enrolled into the course #{@course.name}"
    redirect_to @course
  end

  def analytics
    @course = Course.find(params[:id])
    authorize @course
  end

  private

  def course_params
    params.require(:course).permit(:name, :description, :language)
  end
end
