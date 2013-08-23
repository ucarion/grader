class Submission < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :assignment
  has_many :comments, dependent: :destroy

  has_attached_file :source_code

  validates :author_id, presence: true
  validates :assignment_id, presence: true
  validates_attachment :source_code, presence: true
  validates :grade, numericality: { only_integer: true }, allow_blank: true

  DOCKER_RUBY_IMAGE_ID = '8d7cd7b96168'

  def execute_code!
    image = ruby_image

    file_name = source_code_file_name
    source = File.read(source_code.path).shellescape
    cmd = [ "/bin/bash", "-c", "echo #{source} > #{file_name}; ruby #{file_name}"]

    update_attributes(output: image.run(cmd).attach)
  end

  private

  def ruby_image
    Docker::Image.all.each do |image|
      return image if image.id.starts_with?(DOCKER_RUBY_IMAGE_ID)
    end
  end
end
