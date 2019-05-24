#!/usr/bin/env bash

user="cryo"

docker run -it --rm  \
  --log-opt tag=smurf-pcie \
  --security-opt "apparmor=docker-smurf" \
  -u $(id -u ${user}):$(id -g ${user}) \
  --net host \
  -e DISPLAY=${DISPLAY} \
  -e location=${PWD} \
  -v /home/${user}:/home/${user} \
  -v /data:/data \
  -v ${PWD}/shared:/shared \
  --device /dev/datadev_0 \
  tidair/smurf-pcie:%%VERSION%% $1