#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Write the mirror list
mkdir -p /etc/apt/mirrors
echo "http://deb.debian.org/debian/" > /etc/apt/mirrors/debian.list
echo "http://security.debian.org/debian-security/" > /etc/apt/mirrors/debian-security.list

# Write the sources list
cat > '/etc/apt/sources.list.d/debian.sources' << EOF
Types: deb deb-src
URIs: mirror+file:///etc/apt/mirrors/debian.list
Suites: bookworm bookworm-updates bookworm-backports
Components: main contrib non-free non-free-firmware

Types: deb deb-src
URIs: mirror+file:///etc/apt/mirrors/debian-security.list
Suites: bookworm-security
Components: main contrib non-free non-free-firmware
EOF
echo "# See /etc/apt/sources.list.d/debian.sources" > /etc/apt/sources.list

# Clean and update
apt clean all
apt update
