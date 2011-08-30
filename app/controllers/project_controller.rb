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
                commit.save
            }
        end
    end
end
