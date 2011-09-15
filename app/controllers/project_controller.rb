class ProjectController < ApplicationController


    def coevolution
        if params[:files]
            @p_files = Array.new  
            for p_files_id in params[:files]
                @p_files.push PFile.find p_files_id
            end
            @coevolution_files = Hash.new
            total_commits_files = 0
            @p_files.each do |file| 
                total_commits_files += file.commit_files.count
                for commit_file in file.commit_files
                    for co_file in commit_file.commit.commit_files
                        if co_file.p_file_id != file.id and !@p_files.include? co_file.p_file
                            if @coevolution_files[co_file.p_file].nil?
                                @coevolution_files.store co_file.p_file, 1
                            else
                                @coevolution_files[co_file.p_file] += 1 
                            end
                        end
                    end 
                end
                
            end 
            @coevolution_files.each_key do |file_key|
                @coevolution_files[file_key] = @coevolution_files[file_key].to_f / total_commits_files.to_f
            
            
            end

        end
    end


    def show
        
        if params[:id]
            @project = Project.find params[:id]            

            if !@project.nil?
                @commits = Commit.find :all, :conditions => {:project_id => @project.id}, :order => "date ASC"
                @commits_act = Array.new
                
                @p_files = PFile.find :all, :conditions => {:project_id => @project.id}, :order => "path_name ASC"
                
                @tags = Hash.new
                @ignore_words = ['', '-', '+', '*', 'and', 'or', 'at', 'to', 'if', 'the', 'a', 'an', 'for', 'of', 'in', 'is', 'are', 'be', 'with', 'not', 'from', 'it', 'you', 'she', 'he', 'as', 'when', 'on', 'in', 'by', 'was', 'were', 'i', 'now', 'today', 'more', 'we', 'our', 'they', 'that', 'thoose', 'this', 'add', 'update', 'remove', 'string', 'added', 'removed', 'updated', 'updates', 'fix', 'fixed', 'fixes', 'file', 'integer', 'new', 'use', 'some', 'code', 'plugin', 'message', 'adding', 'so', 'new', 'make', 'take', 'do', 'does', 'did', 'but', 'however', 'function', 'dont', 'isnt', 'arent', 'wasnt', 'werent', 'no', 'will', 'should', 'can', 'could', 'ever', 'strings', 'about', 'only', 'also', 'which', 'work', 'better', 'worrer', 'all', 'one', 'up', 'down', 'get', 'set', 'have', 'has', 'other', 'files', 'check', 'list','out', 'move', 'moved', 'moving', 'change', 'because', 'changed', 'info', 'user', 'need', 'problem', 'case', 'made', 'like', 'liked', 'as', 'just', 'option', 'options', 'its', 'into', 'link', 'links', 'after', 'before'] 
                @count_min_word = 1
                @count_max_word = 1
                for commit in @commits
                    # === cloud tags ===
                    words = commit.description.split " "
                    for word in words
                        word = word.gsub(/[.,:;!()\[\]"'\n]/, '').downcase
                        if !@ignore_words.include? word
                            if @tags[word].nil?
                                @tags.store word, 1    
                            else
                                @tags[word] += 1
                                if @tags[word] > @count_max_word
                                    @count_max_word = @tags[word]
                                end
                            end
                        end
                    end
                end
                
                
=begin

<% @coevolution_files.each_key do |file_key| %>
    <h3><%= file_key.path_name %></h3>
    <table>
        <% @coevolution_files[file_key].each_key do |co_file_key| %>
            <tr>
                <td><%= co_file_key.path_name %></td>
                <td><%= @coevolution_files[file_key][co_file_key] %></td>
                
            </tr>
        <% end %>
    </table>
    <br />
    <br />
<% end %>
=end
                @coevolution_files = Hash.new
                @project.p_files.each{|file| 
                    total_commits_file = file.commit_files.count
                    @coevolution_files.store file, {}
                    for commit_file in file.commit_files
                        for co_file in commit_file.commit.commit_files
                            if co_file.p_file_id != file.id
                                if @coevolution_files[file][co_file.p_file].nil?
                                    @coevolution_files[file].store co_file.p_file, 1
                                else
                                    @coevolution_files[file][co_file.p_file] += 1 
                                end
                            end
                        end 
                    end
                }                
            end
        end
    end

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
        redirect_to "/"
    end
end
