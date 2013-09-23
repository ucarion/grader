class Submission < ActiveRecord::Base
  include PublicActivity::Common
  include SubmissionsHelper

  module Status
    WAITING = 0
    OUTPUT_CORRECT = 1
    OUTPUT_INCORRECT = 2
  end
  
  belongs_to :author, class_name: "User"
  belongs_to :assignment
  has_many :comments, dependent: :destroy
  has_many :source_files


  validates :author_id, presence: true
  validates :assignment_id, presence: true
  validates_attachment :source_code, presence: true
  validates :grade, numericality: { only_integer: true }, allow_blank: true

  after_create :init_status

  def init_status
    update_attributes(status: Status::WAITING, output: nil)
  end

  def status_as_string
    case status
    when Status::WAITING
      "waiting"
    when Status::OUTPUT_CORRECT
      "correct output"
    when Status::OUTPUT_INCORRECT
      "incorrect output"
    end
  end

  def execute_code!
    execute_submission(self)
  end

  handle_asynchronously :execute_code!
end
