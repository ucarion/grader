class AddGracePeriodToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :grace_period, :integer
  end
end
