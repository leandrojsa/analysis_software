class AnalysisController < ApplicationController

  def svn
      #require 'rubygems'
      #gem 'nokogiri'
      if params[:url].nil? and params[:extension].nil?
          flash[:notice] = "Preencha todos os campos."
      else
          system("svn log -v --xml --incremental " + params[:url] + "| sed '1i\<root>' | sed '$a\</root>' > exit2.xml" )
          @extension = params[:extension].gsub(/ /, '').split ','

          file = File.open("exit2.xml")
          @doc = Nokogiri::XML(file)
          file.close
          @num_revisions = 0
          @hash_files = Hash.new
          @matrix_dependence = Hash.new
          bla = Array.new
        @doc.css("logentry").each{ |logentry|
            @num_revisions += 1
            logentry.css("paths").each{|paths|
                bla.each{|a|
                  bla.each{|b|
                    if @matrix_dependence[a + ',' + b].nil?
                        @matrix_dependence[a + ',' + b] = 1
                    else
                      @matrix_dependence[a + ',' + b] += 1
                    end
                  }
                }
                bla = Array.new
                paths.css("path").each{|path|
                    file_path = String.new
                    if !path["copyfrom-path"].nil?
                        file_path = path["copyfrom-path"]
                    end
                    file_path += path.text
                    bla.push file_path
                    if has_file_type @extension, file_path
                        if @hash_files[file_path].nil?
                            @hash_files[file_path] = 1

                        else
                            @hash_files[file_path] += 1
                        end
                    end
                }
            }
        }
      end
  end

  def has_file_type types, file
    types.each{|type|
      rexp = Regexp.new(type + '$')
      if !file.match(rexp).nil?
        return true
      end
    }
    return false
  end

end

