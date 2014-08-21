# Dockerized Development Environment

The Dockerfile contained in this repository may be used to automate much of the establishment of a development environment that uses zsh, vim, and tmux. 

_Disclaimer: This Dockerfile and the related configuration files represent my own development environment, which continues to evolve. Use at your own risk._

#####Background

The development environment established within a docker container is based on my personal development environment (available at [https://github.com/chasdev/config-files](https://github.com/chasdev/config-files)).  The 'config-files' repository contains various configuration files for zsh, vim, tmux and more. This project installs the necessary software and retrieves the configuration files from the referenced 'config-files' repository.  There are currently 'manual steps' that must still be performed. I expect to reduce the manual steps in the future.

References that you may find helpful (and that were important resources used by me when creating this Dockerfile):
* [http://jeffknupp.com/blog/2014/06/30/docker-blurs-the-line-between-saas-and-selfhosted-apps/](http://jeffknupp.com/blog/2014/06/30/docker-blurs-the-line-between-saas-and-selfhosted-apps/)
* [http://www.theodo.fr/blog/2014/01/build-a-zen-command-line-environment-with-git-tmux-oh-my-zsh-mosh-and-docker/](http://www.theodo.fr/blog/2014/01/build-a-zen-command-line-environment-with-git-tmux-oh-my-zsh-mosh-and-docker/)

##Vagrant

[Docker](https://www.docker.com) requires linux so to use on OS X or Windows a (lightweight) linux VM must be used.  When running on OS X or windows, you may use either [Vagrant](https://www.vagrantup.com) or '[boot2docker](https://github.com/boot2docker/boot2docker)'. The following instructions use Vagrant due to limitations of boot2docker (discussed toward the end of this write-up). 

The following assumes you have installed vagrant 1.6. 

#####Build and start a ubuntu VM

```
$ git clone git@github.com:chasdev/dev-env.git
$ cd dev-env
$ vagrant up
$ vagrant ssh
```

The Vagrantfile (and accompanying bootsrap.sh shell script) will install Docker and mount '$HOME/working' on the host (e.g., OS X) as '/working' within the VM. 

#####Building the image and running a container 

From within the Vagrant VM: (you can use another tag versus chasdev/dev-env) 

```
$ cd /vagrant
$ sudo docker build -t chasdev/dev-env .
$ sudo docker run -P -d -v /working:/working --name dev chasdev/dev-env
# Check that it's running and note the port that you will need to ssh into the container 
$ docker ps
# The port is usually 49153, but can differ...
$ ssh me@0.0.0.0 -p 49153
```
This currently (and temporarily) prompts for a password (which is 'me!'). (This still needs to be improved to use keys.)

#####Start vim and install plugins

NOTE: The Dockerfile does not currently install Go (golang), but one of the vim plugins specified in the .vimrc requires Go.  Either install Go or edit the .vimrc file to remove 'vim-go'. (This is a temporary disconnect.)  If you forget, just delete it from .vim/bundles afterwards.

```
$ v .
:PluginInstall
```

This will install all of the plugins listed in the .vimrc file (from 'https://github.com/chasdev/config-files'), using [Vundle](https://github.com/gmarik/Vundle.vim).  

When this is complete, close vim and build the native extensions needed by some of the plugins.

```
cd ~/.vim/bundle/YouCompleteMe
./install.sh
cd ~/.vim/bundle/vimproc
make
```

----

####Alternative - using boot2docker

This option was not used as there are limitations in how to mount OS X folders within the container (which remember is actually running within the vagrant-managed VM).  Unfortunately, there does not appear to be a 'nice' way of using a 'volume' to share files between the docker container and OS X, as there is a lightweight linux VM in the middle which does not provide sufficient flexibility for mapping/mounting volumes. A solution apprears to be in work: [https://github.com/docker/docker/issues/7249](https://github.com/docker/docker/issues/7249) and this issue is discussed in [https://github.com/boot2docker/boot2docker-cli/issues/202](https://github.com/boot2docker/boot2docker-cli/issues/202).

Reference:

* [http://stackoverflow.com/questions/23014684/how-to-get-ssh-connection-with-docker-container-on-osxboot2docker](http://stackoverflow.com/questions/23014684/how-to-get-ssh-connection-with-docker-container-on-osxboot2docker)

Please follow the instructions for installing boot2docker on [OS X](http://docs.docker.com/installation/mac/) or [Windows](http://docs.docker.com/installation/windows/).

#####Stop the VM and fix the port mapping

This is a one-time 'fix' we need to make to ensure we can access the 42222 port running in the container, that is in turn running within the linux VM, from our host system.

```
$ boot2docker stop
$ VBoxManage modifyvm "boot2docker-vm" --natpf1 "containerssh,tcp,,42222,,42222"
```

#####Restart the VM and ssh into the container as user 'me'

```
$ boot2docker up
$ ssh me@0.0.0.0 -p 42222
# The 'me' user password is 'me!'.
```

The best way to share a data volume appears to be using a 'file share container':

```
# Make a volume container (only need to do this once)
$ docker run -v /data --name my-data busybox true
# Share it using Samba (Windows file sharing)
$ docker run --rm -v /usr/local/bin/docker:/docker -v /var/run/docker.sock:/docker.sock svendowideit/samba my-data
# then find out the IP address of your Boot2Docker host
$ boot2docker ip
192.168.59.103
```

Note: There is also a [Vagrant docker provider](https://www.vagrantup.com/blog/feature-preview-vagrant-1-6-docker-dev-environments.html) (although this uses boot2docker under the covers). This warrants further investigation although intitial usage proved problematic. 

