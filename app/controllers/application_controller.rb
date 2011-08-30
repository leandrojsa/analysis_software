class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def get_file_extension filename
    
    extension = filename.split "."
    
    if extension.last != filename and extension.last.length < 5
        return extension.last
    else
        return ""
    end
    
  end
end
