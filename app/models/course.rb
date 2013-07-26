class Course < ActiveRecord::Base
  belongs_to :teacher, class_name: "User"
  has_and_belongs_to_many :students, class_name: "User"
  has_many :assignments

  validates :teacher_id, presence: true
  validates :name, presence: true
  validates :description, presence: true
end
