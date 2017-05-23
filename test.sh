#!/usr/bin/env bash

docker run \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    -p 9091:9091 \
    -v /Users/slamps/Temp/docker/data/:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -e "OPENVPN_PROVIDER=vpntunnel" \
    -e "OPENVPN_CONFIG=Paris" \
    -e "OPENVPN_USERNAME=sebienfait" \
    -e "OPENVPN_PASSWORD=Qe2oYo2Uvl" \
    docker-transmission

