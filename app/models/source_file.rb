class SourceFile < ActiveRecord::Base
  belongs_to :submission

  has_attached_file :code

  validates_attachment :code, presence: true
end
