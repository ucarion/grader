class Ability < Candela::Ability
  def initialize(user)
    can :read, User
    can :index, User
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

      can :create, Assignment do |assignment|
        assignment.course.teacher == user
      end

      can :update, Assignment do |assignment|
        assignment.course.teacher == user
      end

      can :destroy, Assignment do |assignment|
        assignment.course.teacher == user
      end

      can :read, Submission do |submission|
        submission.author == user || submission.assignment.course.teacher == user
      end

      can :create, Submission do |submission|
        submission.assignment.course.students.include?(user) && submission.assignment.open?
      end

      can :update, Submission do |submission|
        submission.assignment.course.students.include?(user) && submission.assignment.open?
      end

      can :grade, Submission do |submission|
        submission.assignment.course.teacher == user
      end

      can :index, Submission do |submissions|
        # Bleckh... this probably can be done in a better way
        assignment = Assignment.find(submissions.where_values_hash["assignment_id"])
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
