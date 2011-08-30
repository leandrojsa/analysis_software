class AddColumnPfile < ActiveRecord::Migration
  def self.up
    add_column :p_files, :commit_id, :integer
  end

  def self.down
  end
end
