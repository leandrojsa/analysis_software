class CommitFile < ActiveRecord::Base

    belongs_to :p_file
    belongs_to :commit
    
    after_save :set_p_file_is_deleted
    
    
    def set_p_file_is_deleted
    
        if self.action_type == 'D'
            p_file =  PFile.find self.p_file_id
            
            p_file.is_deleted = true
            p_file.save
            
        end
        
    end
end
