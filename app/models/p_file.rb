class PFile < ActiveRecord::Base

    belongs_to :project
    has_many :commit_files, :dependent => :delete_all
end
