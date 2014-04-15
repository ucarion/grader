class AddShouldRunTestsToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :should_run_tests, :boolean, default: true
  end
end
