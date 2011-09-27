class AddColumnToPFiles < ActiveRecord::Migration
  def self.up
    add_column :p_files, :is_deleted, :bool, :default => false, :after => :project_id
  end

  def self.down
  end
end
