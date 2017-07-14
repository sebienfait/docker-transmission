#!/usr/bin/env bash

docker stop my-transmission

docker rm my-transmission

docker build . -t docker-transmission

clear

docker run \
    -d \
    --privileged \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    -v /tmp/downloads/:/downloads \
    -v /tmp/config/:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -p 9091:9091 \
    -e "OPENVPN_CONFIG=Paris" \
    -e "OPENVPN_USERNAME=username" \
    -e "OPENVPN_PASSWORD=password" \
    -e "TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=true" \
    -e "TRANSMISSION_RPC_USERNAME=username" \
    -e "TRANSMISSION_RPC_PASSWORD=password" \
    --name my-transmission \
    docker-transmission


