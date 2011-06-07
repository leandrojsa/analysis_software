class AnalysisController < ApplicationController

  def svn
    #require 'rubygems'
    #gem 'nokogiri'
    if params[:url].nil? and params[:extension].nil?
      flash[:notice] = "Preencha todos os campos."
    else
      #%x[svn log -v --xml --incremental  params[:url] >  exit.xml]
      #system("svn log -v --xml --incremental " + params[:url] + " > exit.xml" )
      #@xml = REXML::Document.new File.open("exit.xml")
      @doc = Nokogiri::XML(File.open("exit.xml"))
     # f = File.open("exit.xml")
     # doc = Nokogiri::XML(f)

      #f.close

    end
  end

end

