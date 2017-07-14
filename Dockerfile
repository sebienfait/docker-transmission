# Transmission and OpenVPN
#
# Version 1.15

FROM ubuntu:16.10
MAINTAINER sebienfait

VOLUME /downloads
VOLUME /config

# Update packages and install software
RUN apt-get update \
    && apt-get -y install software-properties-common \
    && apt-get -y install iputils-ping \
    && add-apt-repository multiverse \
    && add-apt-repository ppa:transmissionbt/ppa \
    && apt-get update \
    && apt-get install -y transmission-cli transmission-common transmission-daemon \
    && apt-get install -y openvpn curl rar unrar zip unzip wget \
    && apt-get install -y traceroute \
    && curl -sLO https://github.com/Yelp/dumb-init/releases/download/v1.0.1/dumb-init_1.0.1_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -rf dumb-init_*.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && curl -L https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz | tar -C /usr/local/bin -xzv \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc

ADD openvpn/ /etc/openvpn/
ADD transmission/ /etc/transmission/

EXPOSE 9091

CMD ["dumb-init", "/etc/openvpn/start.sh"]
