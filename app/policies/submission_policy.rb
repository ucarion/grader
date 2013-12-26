class SubmissionPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def show?
    user && (author? || teacher?)
  end

  def create?
    user && enrolled? && open?
  end

  def update?
    user && author? && enrolled? && open?
  end

  private

  def author?
    user === record.author
  end

  def teacher?
    user == record.assignment.course.teacher
  end

  def enrolled?
    record.assignment.course.students.include?(user)
  end

  def open?
    record.assignment.open?
  end
end
