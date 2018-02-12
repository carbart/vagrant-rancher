#!/usr/bin/env ruby
# experimental, ruby is noct installed on basebox
require "fileutils"

def hostsmerger
  hostsfile = "./hosts"
  hostsconfig = "./hosts.config"
  FileUtils.cp(hostsfile, hostsfile + ".org")

  # check if there is already a vagrant config block
  match = File.readlines(hostsfile).select { |line| line =~ /(BEGIN|END) Vagrant Configuration/}

  hostslines = []
  useline = true
  if match.length == 2 then
    File.readlines(hostsfile).each do |line|
      if line =~ /# BEGIN Vagrant Configuration/ then
        useline = false
      elsif line =~ /# END Vagrant Configuration/ then
        useline = true
      elsif useline == true then
        hostslines.push(line)
      end
    end

    open(hostsfile, 'w') do |f|
      f.truncate(0)
      f.puts hostslines.join
    end
  end

  open(hostsfile, 'a') do |f|
    File.readlines(hostsconfig).each { |line| f.puts line }
  end
end

hostsmerger
