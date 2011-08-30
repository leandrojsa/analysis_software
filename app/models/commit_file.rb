class CommitFile < ActiveRecord::Base

    belongs_to :file
    belongs_to :commit
end
