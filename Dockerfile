FROM ubuntu:14.04
MAINTAINER Charlie Hardt <chasdev@me.com>
# References:
#   http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide
#   https://github.com/jpetazzo/nsenter#docker-enter-with-boot2docker
#   https://github.com/thierrymarianne/zen-cmd/blob/master/Dockerfile
#   https://github.com/jeffknupp/docker/blob/master/dev_environment/Dockerfile

# Note: tmux is currently not supported due to lack of tty when using nsenter

# Update repo
RUN apt-get update
RUN apt-get install --only-upgrade bash

# Install git and zshell and packages needed to compile binaries
RUN apt-get install -y -q git curl zsh build-essential autotools-dev automake pkg-config cmake python-dev

# Install and build git-extras
RUN (cd /tmp && git clone --depth 1 https://github.com/visionmedia/git-extras.git && cd git-extras && sudo make install)

# Make directory where repositories are cloned
RUN mkdir /opt/src || echo 'Sources directory exists already'

# Make directory where our command-line tools will installed
RUN mkdir /opt/local || echo 'Local directory exists already'

# Install zsh
RUN apt-get install -y -q zsh

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh

# Create a new zsh configuration from the provided template
# (we'll later back this up and use chasdev/config-files version)
RUN cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
RUN touch /root/.zshrc.include

# Generate UTF-8 locale
RUN locale-gen en_US.UTF-8

EXPOSE 22

# Install vim
RUN apt-get -yq install vim 

# Clone config files 
RUN mkdir -p /root/devtools
RUN git clone https://github.com/chasdev/config-files.git /root/devtools/config-files
RUN ln -s /root/devtools/config-files/.vimrc /root/.vimrc
RUN mv /root/.zshrc /root/.zshrc.bak && ln -s /root/devtools/config-files/.zshrc /root/.zshrc
RUN ln -s /root/devtools/config-files/.bash_profile /root/.bash_profile
RUN ln -s /root/devtools/config-files/.gitconfig /root/.gitconfig
RUN ln -s /root/devtools/config-files/.gitignore /root/.gitignore

RUN git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim
RUN ln -s /root/devtools/config-files/my-snippets /root/.vim/my-snippets

RUN chsh -s /bin/zsh

