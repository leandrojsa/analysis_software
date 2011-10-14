class AddColumnProjectImage < ActiveRecord::Migration
  def self.up
    add_column :projects, :image_file_name, :string, :after => :description
    add_column :projects, :image_content_type, :string, :after => :image_file_name
    add_column :projects, :image_file_size, :string, :after => :image_content_type
  end

  def self.down
  end
end
