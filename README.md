# Dockerized Development Environment

Status:  Under refinement.

The Dockerfile contained in this repository may be used to automate most of the establishment of a zsh and vim based development environment. It currently does not support tmux (due to the lack of a tty when using nsenter).

_Disclaimer: This Dockerfile and the related configuration files represent my own development environment, which continues to evolve. Use at your own risk._

#####Background

The development environment established within a docker container is a subset of my personal development environment (available at [https://github.com/chasdev/config-files](https://github.com/chasdev/config-files)).  The 'config-files' repository contains various configuration files for zsh, vim, tmux and more. This project installs the necessary software and retrieves the configuration files from the referenced 'config-files' repository, although only zsh and vim are dockerized.  There are currently 'manual steps' (described below) that must be performed, although I hope to reduce the manual steps in the future.

References that you may find helpful (and that were important resources used by me when creating this Dockerfile):
* [How to use docker on OS X: the missing guide](http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide)
* [nsenter](https://github.com/jpetazzo/nsenter#docker-enter-with-boot2docker)
* [boot2docker-fwd](https://gist.github.com/deinspanjer/9215467)
* [Docker blurs the line between SAAS and selfhosted apps](http://jeffknupp.com/blog/2014/06/30/docker-blurs-the-line-between-saas-and-selfhosted-apps/)
* [Build a zen command-line environment with git tmux oh-my-zsh and docker](http://www.theodo.fr/blog/2014/01/build-a-zen-command-line-environment-with-git-tmux-oh-my-zsh-mosh-and-docker/)

##boot2docker or Vagrant

[Docker](https://www.docker.com) requires linux so to use on OS X or Windows a (lightweight) linux VM must be used.  When running on OS X or windows, you may use either [Vagrant](https://www.vagrantup.com) or '[boot2docker](https://github.com/boot2docker/boot2docker)'. The following uses boot2docker.

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
export DOCKER_HOST=tcp://192.168.59.103:2375
```

Next we need to replace the boot2docker image with one that includes the VirtualBox guest additions. This is needed to allow easy volume sharing between OS X and the docker container running inside the boot2docker image.

Please read [http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide](http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide) which provides detailed instructions. This blog is the primary guide used and provides more detail than what is included here.

```
$ docker down
$ curl http://static.dockerfiles.io/boot2docker-v1.2.0-virtualbox-guest-additions-v4.3.14.iso > ~/.boot2docker/boot2docker.iso
$ VBoxManage sharedfolder add boot2docker-vm -name home -hostpath /Users
$ boot2docker up
```

Next we'll install nsenter into the boot2docker VM. This will allow us to enter our docker container without running an SSH server.  See [Docker SSH considered evil](http://jpetazzo.github.io/2014/06/23/docker-ssh-considered-evil/) for reasons why this approach is preferrable.

```
$ boot2docker ssh
# docker run --rm -v /var/lib/boot2docker:/target jpetazzo/nsenter
# echo 'export PATH=/var/lib/boot2docker:$PATH' >> ~/.profile
# source ~/.profile
# exit
```

Lastly, add the docker-enter function to your OS X .zshrc or .bash_profile that is listed [here](https://github.com/jpetazzo/nsenter#docker-enter-with-boot2docker), except include within the second 'ssh' command the -t flag (necessary to ensure tty is configured). That is, add the following function:

```
docker-enter() {
  boot2docker ssh '[ -f /var/lib/boot2docker/nsenter ] || docker run --rm -v /var/lib/boot2docker/:/target jpetazzo/nsenter'
  boot2docker ssh -t sudo /var/lib/boot2docker/docker-enter "$@"
}
```

The above function can be used to enter the Docker container without needing to ssh into the containing 'boot2docker' VM first.

#####Build and start a ubuntu VM

```
$ git clone git@github.com:chasdev/dev-env.git
$ cd dev-env
```

_Note: While boot2docker is recommended, the included Vagrantfile (and accompanying bootsrap.sh shell script) can be used to install Docker and mount '$HOME/working' on the host (e.g., OS X) as '/working' within the VM. If using boot2docker you should ignore the Vagrantfile and bootstrap shell script._

#####Building the image and running a container

I keep all of my projects within a '~/working' and the following will map this to '/working' within the container.

```
$ docker build -t chasdev/dev-env .
$ docker run -i -P -d -v /Users/{you}/working:/working --name dev chasdev/dev-env /bin/zsh
$ docker-enter dev
```

#####Start vim and install plugins

Now that the container is up and you have entered it, there are a few manual steps needed to configure vim.  First, we'll install the plugins using Vundle.

_NOTE: The Dockerfile does not currently install Go (golang), but one of the vim plugins specified in the .vimrc requires Go.  Either install Go or edit the .vimrc file to remove 'vim-go'. If you forget, just delete it from .vim/bundles afterwards._

```
$ v .
:PluginInstall
```

This will install all of the plugins listed in the .vimrc file (from 'https://github.com/chasdev/config-files'), using [Vundle](https://github.com/gmarik/Vundle.vim).

When this is complete, close vim and build the native extensions needed by some of the plugins.

```
$ cd ~/.vim/bundle/YouCompleteMe
$ ./install.sh
$ cd ~/.vim/bundle/vimproc
$ make
```

The container should now be usable, providing a command-line centric development
environment comprised of zsh, vim, git, and git-extras.

