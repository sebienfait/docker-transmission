#!/bin/bash

openvpn_config_file="${OPENVPN_CONFIG}"
openvpn_username="${OPENVPN_USERNAME}"
openvpn_password="${OPENVPN_PASSWORD}"
openvpn_config_folder="/etc/openvpn/vpntunnel"
openvpn_config_files=(${openvpn_config_folder}/*.ovpn)
openvpn_login_file="/tmp/.login.temp"

if [ ! -d "${openvpn_config_folder}" ]; then
	echo "Could not find OpenVPN config folder : ${openvpn_config_folder}"
	echo "Please check your settings."
	exit 1
fi

vpn_config_files=(${vpn_config_folder}/*.ovpn)
vpn_config="$(echo $OPENVPN_CONFIG)" 
if [ ! -z "$vpn_config" ]
then
	echo "Using OpenVPN config: $vpn_config"
	vpn_config_file="${vpn_config_folder}/${vpn_config}.ovpn"
	if [ -f $vpn_config_file ]
  	then
		echo "Starting OpenVPN using config ${vpn_config}"
	else docker build
		echo "Supplied config ${vpn_config}.ovpn could not be found."
		vpn_config_file="${vpn_config_files[RANDOM % ${#vpn_config_files[@]}]}"
		echo "Using random OpenVPN config ${vpn_config_file}"
	fi
else
	echo "No VPN configuration provided. Using random config."
	vpn_config_file="${vpn_config_files[RANDOM % ${#vpn_config_files[@]}]}"
	echo "Using random OpenVPN config ${vpn_config_file}"
fi

# add OpenVPN user/pass
if [ "${OPENVPN_USERNAME}" = "**None**" ] || [ "${OPENVPN_PASSWORD}" = "**None**" ] ; then
 echo "OpenVPN credentials not set. Exiting."
 exit 1
else
  echo "Setting OPENVPN credentials..."
  mkdir -p /config
  echo $OPENVPN_USERNAME > /config/openvpn-credentials.txt
  echo $OPENVPN_PASSWORD >> /config/openvpn-credentials.txt
  chmod 600 /config/openvpn-credentials.txt
fi

echo "Add transmission credentials from env vars"
echo $TRANSMISSION_RPC_USERNAME > /config/transmission-credentials.txt
echo $TRANSMISSION_RPC_PASSWORD >> /config/transmission-credentials.txt

echo "Persist transmission settings for use by transmission-daemon"
dockerize -template /etc/transmission/environment-variables.tmpl:/etc/transmission/environment-variables.sh /bin/true

echo "Create Transmission options"
TRANSMISSION_CONTROL_OPTS="--script-security 2 --up /etc/transmission/start.sh --down /etc/transmission/stop.sh"

echo "Launch OpenVPN client"
exec openvpn $TRANSMISSION_CONTROL_OPTS $OPENVPN_OPTS --config "$vpn_config_file"
