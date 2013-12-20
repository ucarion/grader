class SessionsControllerPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def new?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end
end
