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
    language = assignment.course.language

    # Add the files into the image
    files = source_files.map { |file| file.code.path }

    image = docker_image.insert_local('localPath' => files,
      'outputPath' => '/', 'rm' => true)

    # Now, let's generate an image that will run the submission
    cmd = [ "/bin/bash", "-c", cmd_for(language, main_file, assignment.input) ]

    # Run and get output
    container = image.run(cmd)

    messages = container.attach

    stdout = messages[0].join
    stderr = messages[1].join
    output = stdout + stderr

    update_attributes(output: output)

    if outputs_equal?(assignment.expected_output, output)
      update_attributes(status: Submission::Status::OUTPUT_CORRECT)
    else
      update_attributes(status: Submission::Status::OUTPUT_INCORRECT)
    end

    # Cleanup
    container.delete
    image.remove
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

  def outputs_equal?(expected, actual)
    cleanup_output(expected) == cleanup_output(actual)
  end

  def cleanup_output(output)
    output.gsub("\r", "").strip
  end
end
