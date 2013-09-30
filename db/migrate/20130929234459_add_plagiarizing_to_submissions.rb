class AddPlagiarizingToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :plagiarizing, :text
  end
end
