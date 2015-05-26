FROM ubuntu:latest
MAINTAINER Charlie Hardt <chasdev@me.com>

# ------------------------------------------------------------------
# Significant Changes:
#   Now uses ssh versus nsenter, along with the ssh_key_adder.rb from
#   https://github.com/dpetersen/dev-container-base/blob/master/Dockerfile
#   Also uses wemux (again, based upon dpetersen's approach).
#
# References:
#   http://www.centurylinklabs.com/cloud-coding-docker-remote-pairing/
#   https://github.com/dpetersen/dev-container-base
#   http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide
#   https://github.com/thierrymarianne/zen-cmd/blob/master/Dockerfile
#   https://github.com/jeffknupp/docker/blob/master/dev_environment/Dockerfile
#
# The ssh_key_adder.rb file and parts of this Dockerfile have been
# stolen from Don Petersen, who retains all credit and appreciation.
# Please see: 
# https://github.com/dpetersen/dev-container-base/blob/master/ssh_key_adder.rb 
# and his Dockerfile contained in that same repo.
# ------------------------------------------------------------------

ADD ssh_key_adder.rb /root/ssh_key_adder.rb

# Start by changing the apt output, as stolen from Discourse's Dockerfiles.
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections && \

  apt-get update && \
  apt-get install -y openssh-client git build-essential vim ctags man make cmake curl && \
  apt-get install -y python-dev python-software-properties software-properties-common && \
  add-apt-repository -y ppa:pi-rho/dev && \
  apt-get update && \
  apt-get install -y tmux=2.0-1~ppa1~t && \

# Set up for pairing with wemux.
  git clone git://github.com/zolrath/wemux.git /usr/local/share/wemux && \
  ln -s /usr/local/share/wemux/wemux /usr/local/bin/wemux && \
  cp /usr/local/share/wemux/wemux.conf.example /usr/local/etc/wemux.conf && \
  echo "host_list=(root)" >> /usr/local/etc/wemux.conf && \

# Install ruby, which is used for github-auth
  apt-get install -y ruby && \

# Install the Github Auth gem, which will be used to get SSH keys from GitHub
# to authorize users for SSH
  gem install github-auth --no-rdoc --no-ri && \

# Clone config files
  mkdir -p /root/devtools && \
  git clone https://github.com/chasdev/config-files.git /root/devtools/config-files && \
  ln -s /root/devtools/config-files/.vimrc /root/.vimrc && \
  ln -s /root/devtools/config-files/.tmux.conf /root/.tmux.conf && \
  ln -s /root/devtools/config-files/.bash_profile /root/.bash_profile && \
  ln -s /root/devtools/config-files/.gitconfig /root/.gitconfig && \
  ln -s /root/devtools/config-files/.gitignore /root/.gitignore && \
  git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim && \
  ln -s /root/devtools/config-files/my-snippets /root/.vim/my-snippets && \

# Set up SSH with SSH forwarding
  apt-get install -y openssh-server && \
  mkdir /var/run/sshd && \
  echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config && \

# Generate UTF-8 locale
  locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

# install the vim plugins using Vundle plugin manager
RUN vim +PluginInstall +qall > /dev/null 2>&1
RUN cd ~/.vim/bundle/YouCompleteMe && ./install.sh
RUN cd ~/.vim/bundle/vimproc.vim && make 

# Expose SSH
EXPOSE 22

# Install the SSH keys of ENV-configured GitHub users before running the SSH
# server process. See README for SSH instructions.
CMD /root/ssh_key_adder.rb && /usr/sbin/sshd -D

