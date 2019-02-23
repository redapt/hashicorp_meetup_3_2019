#! /bin/bash

sudo export DEBIAN_FRONTEND=noninteractive

sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2376 -j ACCEPT

sudo apt-get update
sudo apt-get upgrade -y

wget -O - get.docker.com | sh
sudo usermod -aG docker ubuntu