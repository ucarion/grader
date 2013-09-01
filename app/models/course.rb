class Course < ActiveRecord::Base
  belongs_to :teacher, class_name: "User"
  has_and_belongs_to_many :students, class_name: "User"
  has_many :assignments, dependent: :destroy

  validates :teacher_id, presence: true
  validates :name, presence: true
  validates :description, presence: true

  def total_points
    sum = 0

    assignments.each do |assignment|
      sum += assignment.point_value
    end

    sum
  end
end
