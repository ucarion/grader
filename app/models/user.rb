class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :taught_courses, class_name: "Course", foreign_key: "teacher_id", dependent: :destroy
  has_and_belongs_to_many :enrolled_courses, class_name: "Course"
  has_many :submissions, foreign_key: "author_id", dependent: :destroy
  has_many :comments
  has_many :activities

  # Shortcuts
  has_many :teachers, -> { uniq }, through: :enrolled_courses
  has_many :students, -> { uniq }, through: :taught_courses

  before_save { email.downcase! }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }

  def name
    "#{first_name} #{last_name}"
  end

  alias_method :full_name, :name

  def assignments(args = {only_open: false})
    courses = "SELECT course_id FROM courses_users WHERE user_id = :user_id"
    assignments = Assignment.where("course_id IN (#{courses})", user_id: id).order("due_time ASC")

    if args[:only_open]
      assignments.select { |assignment| assignment.open? }
    else
      assignments
    end
  end

  def grade_in_course(course)
    sum = 0

    submissions.each do |submission|
      sum += submission.grade || 0 if submission.assignment.course == course
    end

    sum
  end

  def recent_activities(limit)
    Activity.where(user: self).order(created_at: :desc).limit(limit)
  end
end
