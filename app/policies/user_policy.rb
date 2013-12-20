class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
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
end
