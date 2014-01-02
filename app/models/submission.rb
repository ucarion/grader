class Submission < ActiveRecord::Base
  include PublicActivity::Common
  include SubmissionsHelper

  # TODO: make this be an enum
  module Status
    WAITING = 0
    OUTPUT_CORRECT = 1
    OUTPUT_INCORRECT = 2
  end

  serialize :plagiarizing, Array

  belongs_to :author, class_name: "User"
  belongs_to :assignment
  has_many :comments, dependent: :destroy
  has_many :source_files

  accepts_nested_attributes_for :source_files, allow_destroy: true

  validates :author_id, presence: true
  validates :assignment_id, presence: true
  validates :grade, numericality: { only_integer: true }, allow_blank: true
  validate :validate_source_files
  validates_associated :source_files

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

  def main_file
    source_files.find { |file| file.main? }
  end

  private

  def validate_source_files
    if self.source_files.blank?
      errors.add(:source_files, "Submission must have at least one attached file.")
    elsif self.source_files.to_a.count { |file| file.main? } != 1
      errors.add(:source_files, "Submission must have exactly one main file.")
    end
  end
end
