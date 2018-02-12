# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
require_relative "hostsgenerator.rb"

vars = YAML.load_file("vars.yaml")
hostsgenerator(vars)

Vagrant.configure("2") do |config|
	# ============================================================================
	# RANCHER
	config.vm.define "rancher", autostart: true do |rancher|
		settings = vars["vm_rancher"]
		rancher.vm.box = "bento/ubuntu-16.04"
		rancher.vm.synced_folder "data", "/vagrant", disabled: true

		rancher.vm.hostname = settings.fetch("hostname", "rancher")
		rancher.vm.network "private_network", ip: settings.fetch("ip", "193.168.33.10")

		# Set forwarded ports for ssh and additionaly from the YAML-config
		rancher.vm.network "forwarded_port", guest: 22, host: 22000, id: "ssh"
		settings.fetch('forwarded_ports', []).each do |i|
        rancher.vm.network "forwarded_port", guest: i['guest'], host: i['host']
    end

		rancher.vm.synced_folder settings["synced_folder"]["host"], settings["synced_folder"]["guest"], mount_options: ["dmode=0775", "fmode=0775"]

		rancher.vm.provider :virtualbox do |vb|
			vb.memory = "2048"
			vb.gui = false
		end

		# Prepare the hosts setings
		rancher.vm.provision "file", source: "./hosts.config", destination: "hosts.config"
		rancher.vm.provision "file", source: "./hostsmerger.sh", destination: "hostsmerger.sh"
		rancher.vm.provision "shell", privileged: true, inline: <<SHELL
			cd /home/vagrant
			chmod a+x hostsmerger.sh
			./hostsmerger.sh
SHELL

		# Setup the Docker Environment
		rancher.vm.provision "shell", privileged: true, inline: <<SHELL
			apt-get update
			apt-get -y install apt-transport-https ca-certificates curl

			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

			add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

			apt-get update
			apt-get -y install docker-ce=17.12.0~ce-0~ubuntu
SHELL

		# Do some Docker configuration and setup some basic Docker container
		rancher.vm.provision "file", source: "./daemon.json", destination: "daemon.json"
		rancher.vm.provision "shell", privileged: true, env: {"docker_registry" => settings.fetch("ip", "193.168.33.10")}, inline: <<SHELL
			cp /home/vagrant/deamon.json /etc/docker
			systemctl daemon-reload
			systemctl restart docker

			# cleanup
			docker stop $(docker ps -a -q) && docker system prune -a -f && docker system prune --volumes -f

			docker run -d --restart=unless-stopped -p 8080:8080 --name rancher-server rancher/server
			docker run -d --restart=unless-stopped -p 5000:5000 --name registry registry:2
			docker run -d --restart=unless-stopped -p 80:80 --name registry-frontend \
				-e ENV_DOCKER_REGISTRY_HOST=$docker_registry \
				-e ENV_DOCKER_REGISTRY_PORT=5000 \
				konradkleine/docker-registry-frontend:v2
SHELL

	end

	# ============================================================================
	# Storage
	config.vm.define "nfs-node",  autostart: false do |node3|
		node3.vm.box = "bento/ubuntu-16.04"
		node3.vm.synced_folder "data", "/vagrant", disabled: true

		node3.vm.hostname = "nfs-node"
		node3.vm.network "private_network", ip: "192.168.33.13"

		node3.vm.network "forwarded_port", guest: 22, host: 22001, id: "ssh"

		node3.vm.provider :virtualbox do |vb|
			vb.memory = "1024"
			vb.gui = false
		end
		node3.vm.provision "shell", privileged: true, inline: <<SHELL
			apt-get update
			apt-get -y install nfs-kernel-server

			mkdir /nfs
			chown nobody:nogroup /nfs

			echo '/nfs    *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports
			systemctl restart nfs-kernel-server
SHELL
	end

	# ============================================================================
	# NODE 1
	config.vm.define "node1",  autostart: false do |node|
	  settings = vars["vm_docker_1"]
	  node.vm.box = "bento/ubuntu-16.04"
	  node.vm.synced_folder "data", "/vagrant", disabled: true

	  node.vm.hostname = settings.fetch("hostname", "node1.local.net")
	  node.vm.network "private_network", ip: settings.fetch("ip", "193.168.33.12")

	  node.vm.network "forwarded_port", guest: 22, host: 22002, id: "ssh"
	  settings.fetch('forwarded_ports', []).each do |i|
	  		node.vm.network "forwarded_port", guest: i['guest'], host: i['host']
	  end

	  node.vm.provider :virtualbox do |vb|
	    vb.memory = "1024"
	    vb.gui = false
	  end

	  # Prepare the hosts setings
	  node.vm.provision "file", source: "./hosts.config", destination: "hosts.config"
	  node.vm.provision "file", source: "./hostsmerger.sh", destination: "hostsmerger.sh"
	  node.vm.provision "shell", privileged: true, inline: <<SHELL
	    cd /home/vagrant
	    chmod a+x hostsmerger.sh
	    ./hostsmerger.sh
SHELL

	  # Setup the Docker Environment
	  node.vm.provision "shell", privileged: true, inline: <<SHELL
	    apt-get update
	    apt-get -y install apt-transport-https ca-certificates curl

	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	    apt-get update
	    apt-get -y install docker-ce=17.12.0~ce-0~ubuntu
SHELL

	  # Do some Docker configuration and setup some basic Docker container
	  node.vm.provision "file", source: "./daemon.json", destination: "daemon.json"
	  node.vm.provision "shell", privileged: true, inline: <<SHELL
	    cp /home/vagrant/deamon.json /etc/docker
	    systemctl daemon-reload
	    systemctl restart docker
SHELL

	end

	# ============================================================================
	# NODE 2
	config.vm.define "node2",  autostart: false do |node|
	  settings = vars["vm_docker_2"]
	  node.vm.box = "bento/ubuntu-16.04"
	  node.vm.synced_folder "data", "/vagrant", disabled: true

	  node.vm.hostname = settings.fetch("hostname", "node2.local.net")
	  node.vm.network "private_network", ip: settings.fetch("ip", "193.168.33.13")

	  node.vm.network "forwarded_port", guest: 22, host: 22003, id: "ssh"
	  settings.fetch('forwarded_ports', []).each do |i|
	  		node.vm.network "forwarded_port", guest: i['guest'], host: i['host']
	  end

	  node.vm.provider :virtualbox do |vb|
	    vb.memory = "1024"
	    vb.gui = false
	  end

	  # Prepare the hosts setings
	  node.vm.provision "file", source: "./hosts.config", destination: "hosts.config"
	  node.vm.provision "file", source: "./hostsmerger.sh", destination: "hostsmerger.sh"
	  node.vm.provision "shell", privileged: true, inline: <<SHELL
	    cd /home/vagrant
	    chmod a+x hostsmerger.sh
	    ./hostsmerger.sh
SHELL

	  # Setup the Docker Environment
	  node.vm.provision "shell", privileged: true, inline: <<SHELL
	    apt-get update
	    apt-get -y install apt-transport-https ca-certificates curl

	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	    apt-get update
	    apt-get -y install docker-ce=17.12.0~ce-0~ubuntu
SHELL

	  # Do some Docker configuration and setup some basic Docker container
	  node.vm.provision "file", source: "./daemon.json", destination: "daemon.json"
	  node.vm.provision "shell", privileged: true, inline: <<SHELL
	    cp /home/vagrant/deamon.json /etc/docker
	    systemctl daemon-reload
	    systemctl restart docker
SHELL

	end

end
