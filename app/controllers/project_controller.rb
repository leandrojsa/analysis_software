class ProjectController < ApplicationController


    def index
    
        @projects = Project.all
    
    end


    def mount_tree_dir dir_hash, print_array
    
    
        dir_hash.each_key do |part_hash|
    
            if part_hash != 'id'
                print_array.push '<li>'
                if !dir_hash[part_hash]['id'].nil?
                    print_array.push '<input id="files_" name="files[]" type="checkbox" value="' + dir_hash[part_hash]['id'].to_s + '" />'
                end
                
                if !dir_hash[part_hash].nil?
                
                    if dir_hash[part_hash].include? 'id' and dir_hash[part_hash].length == 1

                        print_array.push '<span class="file">' + part_hash + '</span>'
                    else
                        print_array.push '<span class="folder">' + part_hash + '</span>'
                        print_array.push '<ul>'
                        mount_tree_dir dir_hash[part_hash], print_array
                        print_array.push '</ul>'
                    end
               end
                print_array.push '</li>'
            end
            
        end
        
        return print_array
        
    end
    
    def cloud_tags
        @tags = Hash.new
        @ignore_words = ['', '-', '+', '*', 'and', 'or', 'at', 'to', 'if', 'the', 'a', 'an', 'for', 'of', 'in', 'is', 'are', 'be', 'with', 'not', 'from', 'it', 'you', 'she', 'he', 'as', 'when', 'on', 'in', 'by', 'was', 'were', 'i', 'now', 'today', 'more', 'we', 'our', 'they', 'that', 'thoose', 'this', 'add', 'update', 'remove', 'string', 'added', 'removed', 'updated', 'updates', 'fix', 'fixed', 'fixes', 'file', 'integer', 'new', 'use', 'some', 'code', 'plugin', 'message', 'adding', 'so', 'new', 'make', 'take', 'do', 'does', 'did', 'but', 'however', 'function', 'dont', 'isnt', 'arent', 'wasnt', 'werent', 'no', 'will', 'should', 'can', 'could', 'ever', 'strings', 'about', 'only', 'also', 'which', 'work', 'better', 'worrer', 'all', 'one', 'up', 'down', 'get', 'set', 'have', 'has', 'other', 'files', 'check', 'list','out', 'move', 'moved', 'moving', 'change', 'because', 'changed', 'info', 'user', 'need', 'problem', 'case', 'made', 'like', 'liked', 'as', 'just', 'option', 'options', 'its', 'into', 'link', 'links', 'after', 'before',
'improved'] 
        @count_min_word = 1
        @count_max_word = 1
        if params[:begin_date] and params[:end_date] and params[:project_id]
            begin_date = DateTime.new(params[:begin_date]['year'].to_i, params[:begin_date]['month'].to_i,params[:begin_date]['day'].to_i)
            end_date = DateTime.new(params[:end_date]['year'].to_i, params[:end_date]['month'].to_i, params[:end_date]['day'].to_i)
            commits = Commit.find :all, :conditions => {:project_id => params[:project_id], :date => begin_date..end_date}, :order => "date ASC"
            for commit in commits
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
            
        end
    end


    def coevolution
        if params[:files]
            begin_date = DateTime.new(1000,01,01)
            end_date = DateTime.now
            if params[:begin_date] and params[:end_date]
               begin_date = DateTime.new(params[:begin_date]['year'].to_i, params[:begin_date]['month'].to_i,params[:begin_date]['day'].to_i)
               end_date = DateTime.new(params[:end_date]['year'].to_i, params[:end_date]['month'].to_i, params[:end_date]['day'].to_i)
            end
            @p_files = Array.new  
            for p_files_id in params[:files]
                @p_files.push PFile.find p_files_id
            end
            @coevolution_files = Hash.new
            total_commits_files = 0.0
            @p_files.each do |file|
                #total_commits_files += file.commit_files.count
                for commit_file in file.commit_files
                        if commit_file.commit.date >= begin_date and  commit_file.commit.date <= end_date
                            total_commits_files += 1
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
            end 
            @coevolution_files.each_key do |file_key|
                @coevolution_files[file_key] = @coevolution_files[file_key].to_f / total_commits_files
            end
            
        end
    end


    def show
        
        if params[:id]
            @project = Project.find params[:id]            

            if !@project.nil?
                @commits = Commit.find :all, :conditions => {:project_id => @project.id}, :order => "date ASC"#, :limit => 5000
                @commits_act = Array.new
                
                
                
                @p_files = PFile.find :all, :conditions => {:project_id => @project.id}, :order => "path_name ASC"#, :limit => 5000
                directories_tree = {}
                
                for p_file in @p_files
                    path_name = p_file.path_name.split '/'
                    path_name = path_name[1..-1]
                    
                    
                        temp_dir = directories_tree
                        if !path_name.nil?
                            for part in path_name
                                if temp_dir[part].nil?
                                    temp_dir[part] = {'id' => p_file.id}
                                end
                                temp_dir = temp_dir[part]
                            end
                        end
                end
                
                @print_dir = []
                
                @print_dir = mount_tree_dir directories_tree, @print_dir

                
                @tags = Hash.new
                @ignore_words = ['', '-', '+', '*', 'and', 'or', 'at', 'to', 'if', 'the', 'a', 'an', 'for', 'of', 'in', 'is', 'are', 'be', 'with', 'not', 'from', 'it', 'you', 'she', 'he', 'as', 'when', 'on', 'in', 'by', 'was', 'were', 'i', 'now', 'today', 'more', 'we', 'our', 'they', 'that', 'thoose', 'this', 'add', 'update', 'remove', 'string', 'added', 'removed', 'updated', 'updates', 'fix', 'fixed', 'fixes', 'file', 'integer', 'new', 'use', 'some', 'code', 'plugin', 'message', 'adding', 'so', 'new', 'make', 'take', 'do', 'does', 'did', 'but', 'however', 'function', 'dont', 'isnt', 'arent', 'wasnt', 'werent', 'no', 'will', 'should', 'can', 'could', 'ever', 'strings', 'about', 'only', 'also', 'which', 'work', 'better', 'worrer', 'all', 'one', 'up', 'down', 'get', 'set', 'have', 'has', 'other', 'files', 'check', 'list','out', 'move', 'moved', 'moving', 'change', 'because', 'changed', 'info', 'user', 'need', 'problem', 'case', 'made', 'like', 'liked', 'as', 'just', 'option', 'options', 'its', 'into', 'link', 'links', 'after', 'before'] 
                @count_min_word = 1
                @count_max_word = 1
                
                @project_activity = ActiveSupport::OrderedHash.new
                
                for commit in @commits
                    
                    # === activity project ===
                    if @project_activity[commit.date.strftime "%b/%Y"].nil?
                        @project_activity[commit.date.strftime("%b/%Y")] =  1
                    else
                        @project_activity[commit.date.strftime "%b/%Y"] += 1
                    end
                
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
