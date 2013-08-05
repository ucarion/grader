module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = current_user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def signed_in?
    current_user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    current_user == user
  end

  def remember_return_location
    session[:return_loc] = request.url
  end

  def redirect_to_return_or(backup)
    redirect_to(session[:return_loc] || backup)
    session.delete(:return_loc)
  end

  def check_signed_in
    unless signed_in?
      remember_return_location
      redirect_to signin_path, notice: "Sign in before completing this action."
    end
  end

  def check_right_user
    @user = User.find(params[:id])
    redirect_to root_path, notice: "You cannot edit others' information." unless current_user?(@user)
  end

  def check_admin
    redirect_to(root_path) unless current_user.admin?
  end

  def check_editing_own_course
    @course = Course.find(params[:id])
    redirect_to root_path, notice: "You cannot edit others' courses." unless current_user?(@course.teacher)
  end

  def check_editing_own_assignment
    @assignment = Assignment.find(params[:id])
    redirect_to root_path, notice: "You cannot edit others' assignments." unless current_user?(@assignment.course.teacher)
  end
end
