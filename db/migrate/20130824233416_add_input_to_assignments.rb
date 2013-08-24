class AddInputToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :input, :text
  end
end
