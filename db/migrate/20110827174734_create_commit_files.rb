class CreateCommitFiles < ActiveRecord::Migration
  def self.up
    create_table :commit_files do |t|
      t.string :type, :limit => 1
      t.integer :file_id
      t.integer :commit_id
      t.timestamps
    end
  end

  def self.down
    drop_table :commit_files
  end
end
