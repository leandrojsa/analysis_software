class Project < ActiveRecord::Base
    
    has_many :commits, :dependent => :delete_all
    has_many :p_files, :dependent => :delete_all
end
