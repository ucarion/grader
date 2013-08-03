class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions

  default_scope -> { order('due_time ASC') }

  validates :name, presence: true
  validates :description, presence: true
  validates :course_id, presence: true
  validates :due_time, presence: true

  def open?
    Time.now < due_time
  end

  def closed?
    !open?
  end
end
