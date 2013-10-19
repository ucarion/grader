class Ability < Candela::Ability
  def initialize(user)
    if user
      can :update, User do |modified_user|
        modified_user == user
      end

      if user.admin?
        can :destroy, User do |destroyed_user|
          destroyed_user != user
        end
      end
    else
      can :create, User
    end

    can :read, User
    can :index, User, collection: true
  end
end
