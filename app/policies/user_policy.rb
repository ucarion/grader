class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    user && user.admin?
  end

  def show?
    true
  end

  def new?
    true
  end

  def create?
    new?
  end

  def edit?
    user && user == record
  end

  def update?
    edit?
  end

  def destroy?
    user && user.admin? && user != record
  end

  def show_email?
    user && user_is_teacher?
  end

  private

  def user_is_teacher?
    record.teachers.include?(user)
  end
end
