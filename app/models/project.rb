class Project < ActiveRecord::Base
    
    has_many :commits, :dependent => :delete_all
    has_many :p_files, :dependent => :delete_all
    
    has_attached_file :image, :styles =>{:small=>"64x64", :big=>"128x128"}
end
