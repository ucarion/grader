class AddPointValueToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :point_value, :integer
  end
end
