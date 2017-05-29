#!/usr/bin/env bash

docker stop my-docker-transmission

docker rm my-docker-transmission

docker build . -t docker-transmission

clear

docker run \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    -v /Users/slamps/Temp/docker/data/:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -p 9091:9091 \
    -e "OPENVPN_CONFIG=Paris" \
    -e "OPENVPN_USERNAME=username" \
    -e "OPENVPN_PASSWORD=password" \
    -e "TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=true" \
    -e "TRANSMISSION_RPC_USERNAME=username" \
    -e "TRANSMISSION_RPC_PASSWORD=coucou" \
    --name my-docker-transmission \
    docker-transmission


