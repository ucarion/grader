class Comment < ActiveRecord::Base
  include PublicActivity::Common
  
  belongs_to :user
  belongs_to :submission

  default_scope -> { order('created_at ASC') }

  validates :user_id, presence: true
  validates :submission_id, presence: true
  validates :content, presence: true
end
