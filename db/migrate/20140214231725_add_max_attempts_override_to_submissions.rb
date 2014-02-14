class AddMaxAttemptsOverrideToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :max_attempts_override, :integer
  end
end
