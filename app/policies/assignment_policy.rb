class AssignmentPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def create?
    is_teacher?
  end

  def update?
    is_teacher?
  end

  def destroy?
    is_teacher?
  end

  def plagiarism?
    is_teacher?
  end

  def compare?
    is_teacher?
  end

  # This is called when Pundit wants to know if a user can see submissions made
  # for this assignment. This does not correspond to any assignment action --
  # this is called from the submission #index action.
  #
  # `record` is still an assignment in this method.
  def list_submissions?
    is_teacher?
  end

  private

  def is_teacher?
    user && user == record.course.teacher
  end
end
