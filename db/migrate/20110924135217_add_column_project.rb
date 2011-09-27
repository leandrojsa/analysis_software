class AddColumnProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :description, :text, :after => :repository
  end

  def self.down
  end
end
