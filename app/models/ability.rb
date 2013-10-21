class Ability < Candela::Ability
  def initialize(user)
    can :read, User
    can :index, User, collection: true
    can :read, Course

    if user
      can :update, User do |modified_user|
        modified_user == user
      end

      can :create, Course

      can :update, Course do |course|
        course.teacher == user
      end

      can :analytics, Course do |course|
        course.teacher == user
      end

      can :destroy, Course do |course|
        course.teacher == user
      end

      can :enroll, Course do |course|
        course.teacher != user && course.students.exclude?(user)
      end

      if user.admin?
        can :destroy, User do |destroyed_user|
          destroyed_user != user
        end
      end
    else
      can :create, User
    end
  end
end
