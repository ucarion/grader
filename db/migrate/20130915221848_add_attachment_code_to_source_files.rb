class AddAttachmentCodeToSourceFiles < ActiveRecord::Migration
  def self.up
    change_table :source_files do |t|
      t.attachment :code
    end
  end

  def self.down
    drop_attached_file :source_files, :code
  end
end
