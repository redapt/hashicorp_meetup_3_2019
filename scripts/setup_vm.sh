#! /bin/bash

sudo export DEBIAN_FRONTEND=noninteractive

sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2375 -j ACCEPT

wget -O - get.docker.com | sh
sudo usermod -aG docker ubuntu

cat << EOF > /etc/docker/daemon.json
{
    hosts: [
        "unix:///var/run/docker.sock",
        "tcp://0.0.0.0:2375"
    ]
}
EOF

sudo apt-get update
yes | sudo apt-get upgrade

echo "sudo reboot" | at now + 1 minute