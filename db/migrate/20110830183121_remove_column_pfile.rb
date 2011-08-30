class RemoveColumnPfile < ActiveRecord::Migration
  def self.up
    remove_column :p_files, :commit_id
  end

  def self.down
  end
end
