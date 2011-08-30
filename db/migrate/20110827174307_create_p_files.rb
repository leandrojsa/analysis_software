class CreatePFiles < ActiveRecord::Migration
  def self.up
    create_table :p_files do |t|
      t.string :path_name
      t.string :extension
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :p_files
  end
end
