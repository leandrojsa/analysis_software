class Project < ActiveRecord::Base
    
    has_many :commits
    has_many :p_files
end
