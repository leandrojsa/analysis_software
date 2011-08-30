class RenameColumn < ActiveRecord::Migration
  def self.up
    rename_column :commit_files, :file_id, :pfile_id
  end

  def self.down
  end
end
