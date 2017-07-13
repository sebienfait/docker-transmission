#!/bin/bash


#add Open DNS servers
echo "Change DNS for FDN DNS"
echo "nameserver 80.67.169.12" | tee -a /etc/resolv.conf
echo "nameserver 80.67.169.40" | tee -a /etc/resolv.conf

#automatic IP finding
VPN_IP=$4
echo "VPN IP: ${VPN_IP}"
MAIN_IP=$(ip route | awk 'NR==3{print $9}')
echo "Main IP: ${MAIN_IP}"
GATEWAY_IP=$(ip route | awk 'NR==1{print $3}')
echo "GATEWAYIP: ${GATEWAY_IP}"
SUBNET=$(ip route | awk 'NR==2{print $1}')
echo "SUBNET: ${SUBNET}"

ip route add default via $route_vpn_gateway dev $1 table 200
ip rule add from $ifconfig_local table 200
ip route flush cache

echo "-----------------------------------------------------------"
echo "Routes: "
ip route
echo "-----------------------------------------------------------"

. /etc/transmission/start.sh

