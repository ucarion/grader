class Submission < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :assignment

  validates :author_id, presence: true
  validates :assignment_id, presence: true
end
