class ChangeColumnNameCommitFilePfile < ActiveRecord::Migration
  def self.up
   rename_column :commit_files, :pfile_id, :p_file_id
  end

  def self.down
  end
end
