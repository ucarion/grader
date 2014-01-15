# This migration may seem stupid, but it's so that the next migration, generated
# by Devise, can create emails the 'right' way.
class RemoveEmailFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :email
  end
end
