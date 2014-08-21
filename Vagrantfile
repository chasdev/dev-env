# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "joscarsson/ubuntu-trusty64-chef"
  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.synced_folder "/Users/chardt/working", "/working"

end

# NOTE: The following uses the docker provider instead of a 'box'.
# It would (if really working) be used as: vagrant up --provider=docker
#
# Unfortunately, it currently fails retrieving the libc-dev library with a 
# 404 NOT FOUND error.  
#
# The above ubuntu box based approach that is enabled above results in a
# box for each different Dockerfile. Using the docker provider as below 
# is I believe intended to ensure only one box is created and is shared 
# for all docker containers.
#
#VAGRANTFILE_API_VERSION = "2"
#
#Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
#  config.vm.provider "docker" do |d|
#    d.build_dir = "."
#    d.has_ssh = true
#    d.volumes = ["/working"]
#  end
#  config.vm.synced_folder "~/working", "/working"
#end

