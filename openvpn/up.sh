#!/bin/bash


#add Open DNS servers, change to Google's 8.8.8.8 and 8.8.4.4 if you like
#echo "nameserver 209.222.18.222" | tee -a /etc/resolv.conf
#echo "nameserver 209.222.18.218" | tee -a /etc/resolv.conf

echo "$@"

echo "ip route add default via $VPN_GATEWAY dev tap1 table 200"
ip route add default via $VPN_GATEWAY dev tap1 table 200
echo "ip rule add from $LOCAL_IP table 200"
ip rule add from $LOCAL_IP table 200
echo "ip route flush cache"
ip route flush cache


#automatic IP finding
MAINIP=$(ip route | awk 'NR==3{print $9}')
GATEWAYIP=$(ip route | awk 'NR==1{print $3}')
SUBNET=$(ip route | awk 'NR==2{print $1}')
echo "MAINIP: ${MAINIP}"
echo "GATEWAYIP: ${GATEWAYIP}"
echo "SUBNET: ${SUBNET}"

echo "Add IP rule: ip rule add from ${MAINIP} table 128"
#ip rule add from $MAINIP table 128
echo "Add IP route: ip route add table 128 to ${SUBNET} dev eth0"
#ip route add table 128 to ${SUBNET} dev eth0
echo "Add IP route: ip route add table 128 default via ${GATEWAYIP}"
#ip route add table 128 default via ${GATEWAYIP}

. /etc/transmission/start.sh