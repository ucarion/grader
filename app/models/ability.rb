class Ability < Candela::Ability
  def initialize(user)
    can :read, User
    can :index, User, collection: true
    can :read, Course
    can :read, Assignment

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

      can :create, Assignment

      can :update, Assignment do |assignment|
        assignment.course.teacher == user
      end

      can :destroy, Assignment do |assignment|
        assignment.course.teacher == user
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
