class Comment < ActiveRecord::Base
  # TODO add tests for this
  scope :created, -> { where.not(id: nil) }

  belongs_to :user
  belongs_to :submission
  has_many :activities, as: :subject, dependent: :destroy

  default_scope -> { order('created_at ASC') }

  validates :user_id, presence: true
  validates :submission_id, presence: true
  validates :content, presence: true

  def create_activity
    target_user = if user == submission.author
      submission.assignment.course.teacher
    else
      submission.author
    end

    Activity.create(
      subject: self,
      name: 'comment_created',
      user: target_user
    )
  end
end
