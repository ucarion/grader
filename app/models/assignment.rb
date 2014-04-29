class Assignment < ActiveRecord::Base
  include PlagiarismHelper

  belongs_to :course
  has_many :submissions, dependent: :destroy
  has_many :activities, as: :subject, dependent: :destroy

  default_scope -> { order('due_time ASC') }

  validates :name, presence: true
  validates :description, presence: true
  validates :course_id, presence: true
  validates :due_time, presence: true
  validates :point_value, presence: true, numericality: { greater_than: 0 }
  validates :max_attempts, presence: true, numericality: { greater_than: 0 }
  validates :grace_period, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def open?
    Time.now < due_time
  end

  def closed?
    !open?
  end

  def open_or_grace?
    if grace_period
      Time.now < due_time + grace_period.days
    else
      open?
    end
  end

  def average_grade
    sum = 0

    submissions.each do |submission|
      sum += submission.grade || 0
    end

    sum.to_f / submissions.count
  end

  def test_for_plagiarism!
    find_and_report_plagiarism!(self)
  end

  def ungraded_submissions
    submissions.select { |s| s.grade.nil? || s.has_outdated_grade? }
  end

  def create_activities
    course.students.map do |student|
      Activity.create(
        subject: self,
        name: 'assignment_created',
        user: student
      )
    end
  end
end
