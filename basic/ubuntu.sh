#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Write the mirror list
mkdir -p /etc/apt/mirrors
mkdir -p /etc/apt/sources.list.d/bak
# ap-northeast-1.ec2.archive.ubuntu.com
# asia-northeast1.gce.archive.ubuntu.com
echo "http://azure.archive.ubuntu.com/ubuntu/ priority:5" > /etc/apt/mirrors/ubuntu.list
echo "http://archive.ubuntu.com/ubuntu/" >> /etc/apt/mirrors/ubuntu.list
echo "http://security.ubuntu.com/ubuntu/" > /etc/apt/mirrors/ubuntu-security.list
mv /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/bak

# Write the sources list
cat > '/etc/apt/sources.list.d/ubuntu.sources' << EOF
Types: deb deb-src
URIs: mirror+file:///etc/apt/mirrors/ubuntu.list
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb deb-src
URIs: mirror+file:///etc/apt/mirrors/ubuntu-security.list
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
cat > /etc/apt/sources.list << EOF
# Ubuntu sources have moved to the /etc/apt/sources.list.d/ubuntu.sources
# file, which uses the deb822 format. Use deb822-formatted .sources files
# to manage package sources in the /etc/apt/sources.list.d/ directory.
# See the sources.list(5) manual page for details.
EOF

# Clean and update
apt clean all
apt update
