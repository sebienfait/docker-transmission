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

if [ ! -z "${openvpn_config_file}" ]
then
	echo "Using OpenVPN config: ${openvpn_config_file}"
	vpn_config_file="${openvpn_config_folder}/${openvpn_config_file}.ovpn"
	if [ -f ${vpn_config_file} ]
  	then
		echo "Starting OpenVPN using config ${openvpn_config_file}"
	else docker build
		echo "Supplied config ${openvpn_config_file}.ovpn could not be found."
		vpn_config_file="${openvpn_config_files[RANDOM % ${#openvpn_config_files[@]}]}"
		echo "Using random OpenVPN config ${vpn_config_file}"
	fi
else
	echo "No VPN configuration provided. Using random config."
	vpn_config_file="${openvpn_config_files[RANDOM % ${#openvpn_config_files[@]}]}"
	echo "Using random OpenVPN config ${vpn_config_file}"
fi

# add OpenVPN user/pass
if [ "${openvpn_username}" = "**None**" ] || [ "${openvpn_password}" = "**None**" ] ; then
 echo "OpenVPN credentials not set. Exiting."
 exit 1
else
  echo "Setting OPENVPN credentials..."
  echo ${openvpn_username} > ${openvpn_login_file}
  echo ${openvpn_password} >> ${openvpn_login_file}
  chmod 600 ${openvpn_login_file}
fi

echo "Build OpenVPN options"
openvpn_opts="--script-security 2 --up /etc/transmission/start.sh --down /etc/transmission/stop.sh --daemon --route-noexec --auth-user-pass ${openvpn_login_file} ${OPENVPN_OPTS}"
echo "OpenVPN options: ${openvpn_opts}"

echo "Add transmission credentials from env vars"
echo ${TRANSMISSION_RPC_USERNAME} > /tmp/transmission-credentials.txt
echo ${TRANSMISSION_RPC_PASSWORD} >> /tmp/transmission-credentials.txt

echo "Persist transmission settings for use by transmission-daemon"
dockerize -template /etc/transmission/environment-variables.tmpl:/etc/transmission/environment-variables.sh /bin/true

echo "Exec OpenVPN client with options"
exec openvpn --config "${vpn_config_file}" ${openvpn_opts} || rm -f ${openvpn_login_file} && exit $?

echo "End of start"