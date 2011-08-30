class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.integer :number
      t.date :date
      t.string :description
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :commits
  end
end
