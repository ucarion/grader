class CreateSourceFiles < ActiveRecord::Migration
  def change
    create_table :source_files do |t|
      t.references :submission, index: true
      t.boolean :main

      t.timestamps
    end
  end
end
