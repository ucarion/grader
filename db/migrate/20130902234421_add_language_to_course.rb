class AddLanguageToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :language, :string, default: "Ruby"
  end
end
