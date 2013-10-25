class User < ActiveRecord::Base
  has_many :taught_courses, class_name: "Course", foreign_key: "teacher_id", dependent: :destroy
  has_and_belongs_to_many :enrolled_courses, class_name: "Course"
  has_many :submissions, foreign_key: "author_id", dependent: :destroy
  has_many :comments
  
  # Shortcuts
  has_many :teachers, -> { uniq }, through: :enrolled_courses
  has_many :students, -> { uniq }, through: :taught_courses

  has_secure_password

  before_save { email.downcase! }
  before_create :create_remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

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

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
