#!/bin/bash

ping -c 5 -I tun0 bt1.archive.org

. /etc/transmission/start.sh