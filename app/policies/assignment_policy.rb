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

  private

  def is_teacher?
    user && user == record.course.teacher
  end
end
