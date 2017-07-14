#!/bin/bash
openvpn_provider="$(echo ${OPENVPN_PROVIDER} | tr '[A-Z]' '[a-z]')"
openvpn_login_file="/config/.openvpn-credentials.txt"
openvpn_username="${OPENVPN_USERNAME}"
openvpn_password="${OPENVPN_PASSWORD}"
openvpn_config="${OPENVPN_CONFIG}"
openvpn_opts="--route-noexec --script-security 2 --up /etc/openvpn/up.sh --down /etc/openvpn/down.sh ${OPENVPN_OPTS}"

if [ -z "${openvpn_provider}" ]; then
	echo "No VPN provider provided. Using vpntunnel by default."
	openvpn_provider="vpntunnel"
else
    echo "VPN provider provided: ${openvpn_provider}"
fi

openvpn_config_folder="/etc/openvpn/${openvpn_provider}"
if [ ! -d "${openvpn_config_folder}" ]; then
	echo "Could not find VPN config folder ${openvpn_config_folder}. Please check your settings."
	exit 1
else
    echo "VPN config folder: ${openvpn_config_folder}"
fi

if [ -z "${openvpn_config}" ]; then
	echo "No VPN configuration provided. Please check your settings."
	exit 1
else
    echo "VPN configuration provided: ${openvpn_config}"
fi

openvpn_config_file="${openvpn_config_folder}/${openvpn_config}.ovpn"
if [ ! -f ${openvpn_config_file} ]
then
	echo "Could not find VPN config file ${openvpn_config_file}. Please check your settings."
	exit 1
else
    echo "VPN config file: ${openvpn_config_file}"
fi

# add OpenVPN user/pass
if [ -z ${openvpn_username} ] || [ -z ${openvpn_password} ] ; then
 echo "OpenVPN credentials not set. Please check your settings."
 exit 1
fi

echo "Setting OpenVPN credentials with username ${openvpn_username}."
echo ${openvpn_username} > ${openvpn_login_file}
echo ${openvpn_password} >> ${openvpn_login_file}
chmod 600 ${openvpn_login_file}

# Persist environnement variables for future
echo "Setting environnement variables."
dockerize -template /etc/openvpn/environment.tmpl:/etc/environment.sh /bin/true

echo "Starting VPN: exec openvpn --config \"${openvpn_config_file}\" ${openvpn_opts}"
exec openvpn --config "${openvpn_config_file}" --auth-user-pass "${openvpn_login_file}" ${openvpn_opts} || rm -f ${openvpn_login_file} && exit $?
