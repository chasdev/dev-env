# Dockerized Development Environment

The Dockerfile contained in this repository may be used to create a container that provides a vim/tmux based development environment. It uses GitHub to retrieve public keys to facilitate ssh connections.

_Disclaimer: This Dockerfile and referenced [configuration files](https://github.com/chasdev/config-files) represent my own development environment, which continues to evolve. Use at your own risk._

#####Background

Don Petersen's 'dev-container-base' (link below) was a primary source, and much credit and appreciation goes to him. _(Note he uses different vim plugins as well as additional tools such as [homesick](https://github.com/technicalpickles/homesick) and [direnv](http://direnv.net), some of which I may adopt in the future.)_ Following are links to his write-up and repository:

* [Cloud Coding: Remote Pairing using Docker](http://www.centurylinklabs.com/cloud-coding-docker-remote-pairing/)
* [Don Petersen's 'dev-container-base' container](https://github.com/dpetersen/dev-container-base)

In addition, the following references were also helpful:

* [How to use docker on OS X: the missing guide](http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide)
* [boot2docker-fwd](https://gist.github.com/deinspanjer/9215467)
* [Docker blurs the line between SAAS and selfhosted apps](http://jeffknupp.com/blog/2014/06/30/docker-blurs-the-line-between-saas-and-selfhosted-apps/)
* [Build a zen command-line environment with git tmux oh-my-zsh and docker](http://www.theodo.fr/blog/2014/01/build-a-zen-command-line-environment-with-git-tmux-oh-my-zsh-mosh-and-docker/)

## Using boot2docker on OS X

[Docker](https://www.docker.com) requires linux so to use on OS X or Windows a (lightweight) linux VM must be used.  When running on OS X or windows, you may use either [Vagrant](https://www.vagrantup.com) or '[boot2docker](https://github.com/boot2docker/boot2docker)'. I currently use boot2docker, so the following is specific to using boot2docker on OS X.

boot2docker may be installed using a [package installer](https://github.com/boot2docker/osx-installer/releases) or brew.  The package installer will install Docker, the boot2docker ISO, the boot2docker manage tool, and VirtualBox. This will also handle creating an ssh key pair (which may need to be done manually if installing via brew).

If using brew:

```
$ brew tap phinze/homebrew-cask
$ brew install brew-cask
$ brew cask install virtualbox
$ brew install docker
$ brew install boot2docker
$ boot2docker init
```

To start the VM:

```
$ boot2docker up
```

The above will indicate the DOCKER_HOST environment variable must be set if you haven't done this previously.  (If you already use the chasdev/config-files repository to manage your dot-files, this will be set already.)

```
export DOCKER_HOST=tcp://192.168.59.103:2376
```

#####Build and start a ubuntu VM

```
$ git clone git@github.com:chasdev/dev-env.git
$ cd dev-env
```

#####Building the image and running a container

To build the image:

```
$ docker build -t chasdev/dev-env .
```

Next we'll start the container. The following mounts '~/working' as '/working' within the container, as I keep all of my code under this directory. This container allows multiple users who are identified in the comma-deliminated environment variable set below. These users must be GitHub users, and their public keys will be retrieved and added to the container. _(This uses a [ssh_key_adder.rb](https://github.com/dpetersen/dev-container-base/blob/master/ssh_key_adder.rb) ruby script developed by Don Petersen.)_

```
docker run \
-d -e AUTHORIZED_GH_USERS="chasdev" \
-p 0.0.0.0:12345:22 \
-v /Users/chas/working:/working \
chasdev/dev-env:latest
```

Since this container is used as a 'development environment', it uses ssh (which is not a best practice for 'service' containers). Most of your containers should use 'nsenter' in lieu of ssh.

To facilitate connecting to a running container over ssh, we'll set an alias by adding the following to '~/.ssh/config' file. (If using boot2docker, the 'IP or hostname' is that of the vm and not the host. You can determine this IP by using: 'boot2docker ip').

```
Host devbox
  HostName <YOUR IP OR HOSTNAME>
  Port <YOUR MAPPED SSH PORT FROM ABOVE>
  User root
  ForwardAgent true
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```
Now we can connect using:

```
ssh devbox
```

[Vundle](https://github.com/gmarik/Vundle.vim) is used to install all vim plugins listed in the .vimrc file (from 'https://github.com/chasdev/config-files'), and the Dockerfile includes steps to build the necessary native libraries for these plugins. Unlike previous versions of this container, no manual configuration is necessary to use vim, tmux, or wemux.

The container should be usable, providing a command-line centric development environment comprised of bash, vim, tmux, and git. This container should be extended to provide a complete development environment with language-specific support (e.g., node.js, golang, Java/groovy, Scala, etc.).

