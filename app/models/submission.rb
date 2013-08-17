class Submission < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :assignment

  has_attached_file :source_code

  validates :author_id, presence: true
  validates :assignment_id, presence: true
  validates_attachment :source_code, presence: true
  validates :grade, numericality: { only_integer: true }, allow_blank: true
end
