#! /bin/bash

sudo export DEBIAN_FRONTEND=noninteractive

sudo ufw allow ssh
yes | sudo ufw enable
sudo apt-get update
sudo apt-get upgrade -y

wget -O - get.docker.com | sh
sudo usermod -aG docker ubuntu