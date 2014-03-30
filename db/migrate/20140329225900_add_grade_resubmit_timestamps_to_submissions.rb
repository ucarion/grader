class AddGradeResubmitTimestampsToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :last_submitted_at, :datetime
    add_column :submissions, :last_graded_at, :datetime
  end
end
