#!/usr/bin/env ruby
require "yaml"

def hostsgenerator(vars)
  hostsconfig = []
  [vars["vm_rancher"], vars["vm_storage"], vars["vm_docker_1"], vars["vm_docker_2"]].each do |vm|
    hostsconfig.push([vm["ip"], vm["hostname"]])
    if vm["aliases"].respond_to?("each")
      vm["aliases"].each do |a|
        hostsconfig.push([vm["ip"], a])
      end #aliases.each
    end #if aliases
  end #vm

  # write config file
  open('hosts.config', 'wb') do |f|
    hostsconfig.each { |h| f.puts h.join("\t") }
  end
end
