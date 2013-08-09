class AddGradeToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :grade, :integer
  end
end
