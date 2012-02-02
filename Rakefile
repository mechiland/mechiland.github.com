#!/usr/bin/env ruby
#
#require 'rake'

namespace :gs960 do
  desc "Update 960.gs CSS framework by downloading the latest version" 
  task :update do
    sh "rm -rf css/960gs/*"
    sh "git clone http://github.com/nathansmith/960-Grid-System.git"
    sh "cp -R 960-Grid-System/code/css/*.css css/960gs/"
    sh "rm -rf 960-Grid-System"
  end
end


require 'time'

desc "Create a new post based on current date"
task :new_post do
  print "post-title: "
  title = STDIN.gets.strip
  file = Time.new.strftime("%Y-%m-%d-#{title}.md")
  sh "cp _includes/template.md _posts/#{file}"
end

