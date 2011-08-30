class ChangeColumnNameCommitFile < ActiveRecord::Migration
  def self.up
    rename_column :commit_files, :type, :action_type
  end

  def self.down
  end
end
