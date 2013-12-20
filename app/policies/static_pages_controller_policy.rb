class StaticPagesControllerPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def home?
    true
  end

  def help?
    true
  end

  def about?
    true
  end
end
