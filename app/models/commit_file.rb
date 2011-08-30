class CommitFile < ActiveRecord::Base

    belongs_to :p_file
    belongs_to :commit
end
