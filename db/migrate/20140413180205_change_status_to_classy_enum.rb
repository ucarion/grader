class ChangeStatusToClassyEnum < ActiveRecord::Migration
  class Submission < ActiveRecord::Base
  end

  def up
    def convert_status(old_status)
      case old_status
      when 0
        "waiting"
      when 1
        "correct"
      when 2
        "incorrect"
      end
    end

    say "Converting from int- to string-based statuses for submissions."

    # We are going to be changing status from an integer to a string
    # (classy_enum), but we want convert existing data too.
    #
    # First, we'll keep a hash of id => status_as_string.
    new_statuses = Hash[
      Submission.all.map { |s| [s.id, convert_status(s.status)] }
    ]

    # Now let's make the change ...
    change_column :submissions, :status, :string
    Submission.reset_column_information

    # And reload the data
    new_statuses.each do |id, status|
      say "Giving submission #{id} status: #{status}", true

      submission = Submission.find(id)
      submission.status = status
      submission.save!
    end
  end
end
