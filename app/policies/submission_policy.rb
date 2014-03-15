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
    user && enrolled? && open_or_grace? && !preexisting_submission?
  end

  def update?
    user && author? && enrolled? && open_or_grace? && !attempts_exceeded?
  end

  def grade?
    user && teacher?
  end

  def override_max_attempts?
    user && teacher?
  end

  def destroy?
    user && teacher?
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

  def open_or_grace?
    record.assignment.open_or_grace?
  end

  def attempts_exceeded?
    record.num_attempts >= record.max_attempts
  end

  def preexisting_submission?
    record.assignment.submissions.where(author: user).any?
  end
end
