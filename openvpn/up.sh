#!/bin/bash


#add Open DNS servers
echo "Change DNS for FDN DNS"
echo "nameserver 80.67.169.12" | tee -a /etc/resolv.conf
echo "nameserver 80.67.169.40" | tee -a /etc/resolv.conf

#automatic IP finding
MAIN_IP=$(ip route | awk 'NR==3{print $9}')
VPN_IP=$4
echo "Main IP: ${MAIN_IP}"
echo "VPN IP: ${VPN_IP}"

. /etc/transmission/start.sh

