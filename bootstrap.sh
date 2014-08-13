sudo apt-get -y install docker.io
sudo usermod -aG docker vagrant
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
#sudo docker build -t chardt/dev-env /vagrant/Dockerfile
#sudo docker run -P -d --name dev-env chardt/dev-env
#sudo docker ps

