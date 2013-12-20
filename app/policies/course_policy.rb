class CoursePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def show?
    true
  end

  def edit?
    user && user == record.teacher
  end

  def update?
    edit?
  end

  def new?
    user
  end

  def create?
    new?
  end

  def enroll?
    user && user != record.teacher && record.students.exclude?(user)
  end

  def destroy?
    user && user == record.teacher
  end

  def analytics?
    user && user == record.teacher
  end
end
