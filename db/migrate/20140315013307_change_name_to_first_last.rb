class ChangeNameToFirstLast < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    say "Converting user names into first and last names"

    User.reset_column_information

    users = User.all

    users.each do |user|
      user.first_name, user.last_name = user.name.split(' ')

      say "First: #{user.first_name}, last: #{user.last_name}", true

      user.save
    end

    remove_column :users, :name
  end

  def down
    add_column :users, :name, :string

    User.reset_column_information

    users = User.all

    users.each do |user|
      user.name = [user.first_name, user.last_name].join(' ')
      user.save
    end

    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
