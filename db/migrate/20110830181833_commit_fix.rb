class CommitFix < ActiveRecord::Migration
  def self.up
    change_column :commits, :date, :datetime
  end

  def self.down
  end
end
