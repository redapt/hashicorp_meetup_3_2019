#! /bin/bash

DEBIAN_FRONTEND=noninteractive

[[ $(id -u) -eq 0 ]] || exec sudo /bin/bash -c "$(printf '%q ' "$BASH_SOURCE" "$@")"

sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2375 -j ACCEPT

wget -O - get.docker.com | sh
sudo usermod -aG docker ubuntu

echo "Creating Docker Daemon config"
sudo mkdir /etc/systemd/system/docker.service.d
sudo cat << EOF > /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
EOF

echo "upgrading binaries"
sudo apt-get update
yes | sudo apt-get -o Dpkg::Options::="--force-confold" upgrade

echo "sudo reboot" | at now + 2 minute
echo "machine configured!"