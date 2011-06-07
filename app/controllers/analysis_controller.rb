class AnalysisController < ApplicationController

  def svn
    #require 'rubygems'
    #gem 'nokogiri'
    if params[:url].nil? and params[:extension].nil?
      flash[:notice] = "Preencha todos os campos."
    else
      #system("svn log -v --xml --incremental " + params[:url] + " > exit.xml" )
      @doc = Nokogiri::XML(File.open("exit.xml"))

      @num_revisions = 0
      @hash_files = Hash.new
      @doc.css("logentry").each{ |logentry|
        @num_revisions += 1
        logentry.css("paths").each{|paths|
          paths.css("path").each{|path|
            file_path = String.new
            if !path["copyfrom-path"].nil?
              file_path = path["copyfrom-path"]
            end
            file_path += path.text
            if @hash_files[file_path].nil?
              @hash_files[file_path] = 1
            else
              @hash_files[file_path] += 1
            end

          }

        }

      }
    end
  end

end

