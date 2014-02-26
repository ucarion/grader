class CoursePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def show?
    true
  end

  def update?
    is_teacher?
  end

  # Just a cute method for views to use to see if they should show certain
  # things; in reality, verifying if a particular assignment can be created is
  # handled in the assignment policy, not this one.
  def add_assignments?
    update?
  end

  def create?
    user && user.teacher?
  end

  def enroll?
    user && user != record.teacher && record.students.exclude?(user)
  end

  def destroy?
    is_teacher?
  end

  def analytics?
    is_teacher?
  end

  private

  def is_teacher?
    user && user == record.teacher
  end
end
