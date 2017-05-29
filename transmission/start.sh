#!/bin/bash

# Source our persisted env variables from container startup
. /etc/environment.sh

# This script will be called with tun/tap device name as parameter 1, and local IP as parameter 4
# See https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html (--up cmd)
echo "Updating TRANSMISSION_BIND_ADDRESS_IPV4 to the ip of $1 : $4"
export TRANSMISSION_BIND_ADDRESS_IPV4=$4

echo "Generating transmission settings.json from env variables"
# Ensure TRANSMISSION_HOME is created
mkdir -p ${TRANSMISSION_HOME}
dockerize -template /etc/transmission/settings.tmpl:${TRANSMISSION_HOME}/settings.json /bin/true

if [ ! -e "/dev/random" ]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

#add Open DNS servers, change to Google's 8.8.8.8 and 8.8.4.4 if you like
echo "nameserver 209.222.18.222" | tee -a /etc/resolv.conf
echo "nameserver 209.222.18.218" | tee -a /etc/resolv.conf

#automatic IP finding
MAINIP=$(ip route | awk 'NR==3{print $9}')
GATEWAYIP=$(ip route | awk 'NR==1{print $3}')
SUBNET=$(ip route | awk 'NR==2{print $1}')

echo "Add IP rule: ip rule add from ${MAINIP} table 128"
#ip rule add from $MAINIP table 128
echo "Add IP route: ip route add table 128 to ${SUBNET} dev eth0"
#ip route add table 128 to ${SUBNET} dev eth0
echo "Add IP route: ip route add table 128 default via ${GATEWAYIP}"
#ip route add table 128 default via ${GATEWAYIP}

echo "Starting Transmission"
exec /usr/bin/transmission-daemon -g ${TRANSMISSION_HOME} --logfile ${TRANSMISSION_HOME}/transmission.log &

echo "Transmission startup script complete."
