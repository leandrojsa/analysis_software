class ProjectController < ApplicationController

    def new
        @project = Project.new
        
        respond_to do |format|
            format.html # new.html.erb
        format.xml  { render :xml => @project }
    end
    end

    def create
        @project = Project.new(params[:project])
        
        if @project.save
            system("svn log -v --xml --incremental " + @project.repository + "| sed '1i\<root>' | sed '$a\</root>' > exit2.xml" )
           
            file = File.open("exit2.xml")
            doc = Nokogiri::XML(file)
            file.close
            doc.css("logentry").each{ |logentry|
                commit = Commit.new
                commit.number = logentry["revision"]
                commit.date = logentry.css("date").text
                commit.project = @project
                commit.description = logentry.css("msg").text
                if commit.save
                    logentry.css("paths").each{|paths|
                        paths.css("path").each{|path|              
                            file_path = String.new
                            if !path["copyfrom-path"].nil?
                                file_path = path["copyfrom-path"]
                            end
                            file_path += path.text
                            
                            p_file = PFile.find_by_path_name_and_project_id file_path, @project.id
                            
                            if p_file.nil?                            
                                p_file = PFile.new    
                                p_file.path_name = file_path
                                p_file.project = @project
                                p_file.extension = get_file_extension file_path
                                p_file.save
                            end
                            
                            commit_file = CommitFile.new
                            commit_file.p_file = p_file
                            commit_file.commit = commit
                            commit_file.action_type = path["action"]
                            commit_file.save                             
                            
                        }
                    }
                end
            }
        end
    end
end
