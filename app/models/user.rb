class User < ActiveRecord::Base
  has_many :taught_courses, class_name: "Course", foreign_key: "teacher_id", dependent: :destroy
  has_and_belongs_to_many :enrolled_courses, class_name: "Course"

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
    if args[:only_open]
      Assignment.where("course_id IN (#{courses}) AND due_time > :current_time", 
        user_id: id, current_time: Time.now).order("due_time ASC")
    else
      Assignment.where("course_id IN (#{courses})", user_id: id).order("due_time ASC")
    end
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
