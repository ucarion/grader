class AddStatusToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :status, :integer
  end
end
