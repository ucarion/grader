class ChangeSubmissionsGradeToFloat < ActiveRecord::Migration
  def change
    change_column :submissions, :grade, :float
  end
end
