#!/usr/bin/env bash

docker stop my-docker-openvpn

docker rm my-docker-openvpn

docker build . -t docker-openvpn

clear

docker run \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    -v /Users/slamps/Temp/docker/data/:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -p 9091:9091 \
    -e "OPENVPN_PROVIDER=vpntunnel" \
    -e "OPENVPN_CONFIG=Paris" \
    -e "OPENVPN_USERNAME=sebienfait" \
    -e "OPENVPN_PASSWORD=password" \
    -e "TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=true" \
    -e "TRANSMISSION_RPC_USERNAME=sebienfait" \
    -e "TRANSMISSION_RPC_PASSWORD=coucou" \
    --name my-docker-openvpn \
    docker-openvpn


