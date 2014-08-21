_Disclaimer: This Dockerfile and the related configuration files represent my own development environment. Use at your own risk. This repo is subject to change._

# Dockerized Development Environment

The Dockerfile contained in this repository may be used to automate much of the establishment of a development environment that uses zsh, vim, and tmux. 

Specifically, the development environment established within the docker container is based on my personal development enviornment available at [https://github.com/chasdev/config-files](https://github.com/chasdev/config-files).  The referenced 'config-files' repository contains various configuration files for zsh, vim, tmux and more. This project (consisting mostly of a Vagrantfile and a Dockerfile) installs the applications and retrieves the configuration files, however there are 'manual steps' that must still be performed. 

References that you may find helpful (and that were important resources used by me when creating this Dockerfile):
* [http://jeffknupp.com/blog/2014/06/30/docker-blurs-the-line-between-saas-and-selfhosted-apps/](http://jeffknupp.com/blog/2014/06/30/docker-blurs-the-line-between-saas-and-selfhosted-apps/)
* [http://www.theodo.fr/blog/2014/01/build-a-zen-command-line-environment-with-git-tmux-oh-my-zsh-mosh-and-docker/](http://www.theodo.fr/blog/2014/01/build-a-zen-command-line-environment-with-git-tmux-oh-my-zsh-mosh-and-docker/)

## Docker

[Docker](https://www.docker.com) requires linux so to use on OS X or Windows a (lightweight) linux VM must be used.  When running on OS X or windows, you may use either [Vagrant](https://www.vagrantup.com) or '[boot2docker](https://github.com/boot2docker/boot2docker)'. The following instructions use Vagrant due to limitations of boot2docker (discussed toward the end of this write-up). 

#####Build and start a linux VM

```
$ git clone {this repo}
$ cd dev-env
$ vagrant up
$ vagrant ssh
```

#####Building the image and running a container 

From within the Vagrant VM: 

```
$ sudo docker build -t chasdev/dev-env .
$ sudo docker run -P -d -v /working:/working --name dev chasdev/dev-env
# Check that it's running and use the identified port to ssh into the container 
$ docker ps
$ ssh me@0.0.0.0 -p 49153
```

#####Start vim and install plugins

NOTE: The Dockerfile does not currently install Go (golang), but one of the vim plugins specified in the .vimrc requires Go.  Either install Go or edit the .vimrc file to remove 'vim-go'. (This is a temporary disconnect.)

```
$ v .
:PluginInstall
```

This will install all of the plugins listed in the .vimrc file (from 'https://github.com/chasdev/config-files', using Vundle.  

When this is complete, close vim and build the native extensions needed by some of the plugins.

```
cd ~/.vim/bundle/YouCompleteMe
./install.sh
cd ~/.vim/bundle/vimproc
make
```

----

####Alternative - using boot2docker

This option was not used as there are limitations in how to mount OS X folders within the container (that is running within the linux VM), which are discussed below. 

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

Unfortunately, there does not appear to be a 'nice' way of using a 'volume' to share files between the docker container and OS X, as there is a lightweight linux VM in the middle which does not provide sufficient flexibility for mapping/mounting volumes. A solution apprears to be in work: [https://github.com/docker/docker/issues/7249](https://github.com/docker/docker/issues/7249) and this issue is discussed in [https://github.com/boot2docker/boot2docker-cli/issues/202](https://github.com/boot2docker/boot2docker-cli/issues/202).

If you really want to use boot2docker, you may be able to use a 'file share container' to provide this capabiity:

```
# Make a volume container (only need to do this once)
$ docker run -v /data --name my-data busybox true
# Share it using Samba (Windows file sharing)
$ docker run --rm -v /usr/local/bin/docker:/docker -v /var/run/docker.sock:/docker.sock svendowideit/samba my-data
# then find out the IP address of your Boot2Docker host
$ boot2docker ip
192.168.59.103
```

Note: There is also a [Vagrant docker provider](https://www.vagrantup.com/blog/feature-preview-vagrant-1-6-docker-dev-environments.html) (altough this uses boot2docker under the covers). This warrants further investigation altough intitial usage proved problematic. 

