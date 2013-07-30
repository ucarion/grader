class AddDueTimeToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :due_time, :datetime
  end
end
