class Assignment < ActiveRecord::Base
  belongs_to :course

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
