class AddExpectedOutputToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :expected_output, :text
  end
end
