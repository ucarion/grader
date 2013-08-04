class AddAttachmentSourceCodeToSubmissions < ActiveRecord::Migration
  def self.up
    change_table :submissions do |t|
      t.attachment :source_code
    end
  end

  def self.down
    drop_attached_file :submissions, :source_code
  end
end
