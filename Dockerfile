FROM ubuntu:14.04
MAINTAINER Charlie Hardt <chasdev@me.com>
# References:
#   https://github.com/thierrymarianne/zen-cmd/blob/master/Dockerfile
#   https://github.com/jeffknupp/docker/blob/master/dev_environment/Dockerfile
#   http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide
#   https://github.com/jpetazzo/nsenter#docker-enter-with-boot2docker

# Update repo
RUN apt-get update

# Install git and zshell and packages needed to compile binaries
RUN apt-get install -y -q git curl zsh build-essential autotools-dev automake pkg-config cmake python-dev

# Make directory where repositories are cloned
RUN mkdir /opt/src || echo 'Sources directory exists already'

# Make directory where our command-line tools will installed
RUN mkdir /opt/local || echo 'Local directory exists already'

# Clone tmux code repository
RUN git clone git://git.code.sf.net/p/tmux/tmux-code /opt/src/tmux-code

# Fetch latest modifications in case the script should be re-run
RUN cd /opt/src/tmux-code && git fetch --all && git checkout tags/1.9

# Install tmux dependencies
RUN apt-get install -y -q libncurses5-dev libevent-dev

# Configure tmux installation
RUN cd /opt/src/tmux-code && apt-get install -y -q  && sh autogen.sh && ./configure --prefix=/opt/local/tmux

# Compile tmux and install its binaries
RUN cd /opt/src/tmux-code && make && make install && ln -s /opt/local/tmux/bin/tmux /usr/bin

## Install oh-my-zsh ##

# Install zsh
RUN apt-get install -y -q zsh

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh

# Create a new zsh configuration from the provided template
# (we'll later back this up and use chasdev/config-files version)
RUN cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc

# Generate UTF-8 locale
RUN locale-gen en_US.UTF-8

EXPOSE 22

# Install vim
RUN apt-get -yq install vim 

# Clone config files 
RUN mkdir -p /root/devtools
RUN git clone https://github.com/chasdev/config-files.git /root/devtools/config-files
RUN ln -s /root/devtools/config-files/.vimrc /root/.vimrc
RUN mv /root/.zshrc /root/.zshrc.bak && ln -s /root/devtools/config-files/.zshrc
RUN ln -s /root/devtools/config-files/.bash_profile /root/.bash_profile
RUN ln -s /root/devtools/config-files/.tmux.conf /root/.tmux.conf

RUN git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim

RUN echo "To set up your vim environment, run the command :PluginInstall after launching vim." >> README

