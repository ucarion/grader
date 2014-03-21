class ChangeToNewActivityTable < ActiveRecord::Migration
  def up
    drop_table :activities

    create_table :activities do |t|
      t.references :subject, polymorphic: true
      t.references :user, index: true
      t.string :name
    end
  end
end
