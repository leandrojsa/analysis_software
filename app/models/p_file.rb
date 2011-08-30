class PFile < ActiveRecord::Base

    belongs_to :project
    has_many :commit_files
end
