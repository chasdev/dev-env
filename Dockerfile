FROM ubuntu:14.04
MAINTAINER Charlie Hardt <chasdev@me.com>
# Example Dockerfiles used for reference:
#   https://github.com/thierrymarianne/zen-cmd/blob/master/Dockerfile
#   https://github.com/jeffknupp/docker/blob/master/dev_environment/Dockerfile

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

# Create user
RUN useradd -m -s /bin/zsh me

# Set a password for 'me'
RUN echo "me!\nme!" | passwd me

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~me/.oh-my-zsh

# Create a new zsh configuration from the provided template
# (we'll later back this up and use chasdev/config-files version)
RUN cp ~me/.oh-my-zsh/templates/zshrc.zsh-template ~me/.zshrc

# Install openssh server
RUN apt-get install -yq openssh-server

# Disablea password authentication
#RUN sed -i -e 's/^#PasswordAuthentication\syes/PasswordAuthentication no/' /etc/ssh/sshd_config

# pam_loginuid is disabled
#RUN sed -i -e 's/^\(session\s\+required\s\+pam_loginuid.so$\)/#\1/' /etc/pam.d/sshd

# Set zsh as default shell
RUN chsh -s /bin/zsh me

# Generate UTF-8 locale
RUN locale-gen en_US.UTF-8

# Create missing privilege separation directory
RUN mkdir /var/run/sshd

# Make ssh directory of 'me' user
RUN mkdir ~me/.ssh

# Copy ssh keys pair to home directory of 'me' user
#ADD id_boot2docker.pub /home/me/.ssh/authorized_keys

EXPOSE 22

# Install vim
RUN apt-get -yq install vim 

# Continue as user 'me' and from that user's home
USER me
WORKDIR /home/me

# Clone config files 
RUN mkdir -p devtools
RUN git clone https://github.com/chasdev/config-files.git devtools/config-files
RUN ln -s devtools/config-files/.vimrc
RUN mv .zshrc .zshrc.bak && ln -s devtools/config-files/.zshrc
RUN ln -s devtools/config-files/.bash_profile
RUN ln -s devtools/config-files/.tmux.conf

RUN git clone https://github.com/gmarik/Vundle.vim.git ~me/.vim/bundle/Vundle.vim

# Create .zshrc.include file to prepare for manually installed tools
#RUN echo "export LD_LIBRARY_PATH=/home/me/lib:$LD_LIBRARY_PATH\n" > .zshrc.include

RUN echo "To set up your vim environment, run the command :PluginInstall after launching vim." >> README

# Lastly, as root, we'll start up ssh...
USER root
CMD    ["/usr/sbin/sshd", "-D"]
