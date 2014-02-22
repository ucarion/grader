class AddEnrollKeyToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :enroll_key, :string
  end
end
