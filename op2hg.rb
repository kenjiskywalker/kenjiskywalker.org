#!/usr/bin/env ruby

#/usr/bin/env ruby

require 'fileutils'

DIR = "./content/post/"
SOURCE_DIR = "../../../source/_posts/"

Dir.chdir(DIR)

# BEFORE: content/post/2013-03-09-monitoringcasualvol3.markdown
# AFTER:  content/post/2013/03/09/monitoringcasualvol3.markdown

list = `ls #{SOURCE_DIR}`.split("\n")
list.each do |f|
  next if File.directory?(f)
  next unless f =~ /-/
  /([0-9]{4}-[0-9]{2}-[0-9]{2}-)(.*$)/ =~ f
  y, m, d = Regexp.last_match(0).split("\-")
  file_name = Regexp.last_match(2)

  Dir.mkdir("./#{y}") unless File.directory?("./#{y}")
  Dir.mkdir("./#{y}/#{m}") unless File.directory?("./#{y}/#{m}")
  Dir.mkdir("./#{y}/#{m}/#{d}") unless File.directory?("./#{y}/#{m}/#{d}")
  moved_file = "./#{y}/#{m}/#{d}/#{file_name}"
  source_file = SOURCE_DIR + f
  FileUtils.cp(source_file, moved_file)
end

