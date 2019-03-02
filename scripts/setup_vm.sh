#! /bin/bash

sudo export DEBIAN_FRONTEND=noninteractive

sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2376 -j ACCEPT

wget -O - get.docker.com | sh
sudo usermod -aG docker ubuntu

sudo apt-get update
yes | sudo apt-get upgrade

echo "sudo reboot" | at now + 1 minute