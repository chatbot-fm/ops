#!/usr/bin/env bash

#set -e

#if [ "$(uname)" == "Linux" ]; then
#  sudo service docker start
#  sudo mkdir /sys/fs/cgroup/systemd
#  sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
#  sudo modprobe wireguard
#fi

docker-compose up -d
docker exec -t tools sudo service ssh start
#docker exec -ti tools tmux attach
