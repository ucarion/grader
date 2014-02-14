class AddNumAttemptsToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :num_attempts, :integer
  end
end
