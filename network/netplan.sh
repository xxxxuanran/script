#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

install_packages() {
    apt-get update
    apt-get install -y netplan.io
    apt-get remove ifupdown
}

FILE_FULL_PATH=/etc/netplan/50-static.yaml

# Get the name of the first non-lo interface
INTERFACE=$(ip -o link | awk -F': ' '$2 != "lo" {print $2}' | head -n 1 | cut -d'@' -f1)
ALTNAME_LIST=$(ip -o link show $INTERFACE | grep -o 'altname enp[^ ]*' | cut -d' ' -f2)

if [ -n "$ALTNAME_LIST" ]; then
    INTERFACE=$(echo "$ALTNAME_LIST" | head -n 1)
fi

echo "Selected interface: $INTERFACE"

# Get MAC address
MAC_ADDRESS=$(ip link show $INTERFACE | awk '/link\/ether/ {print $2}')
echo "MAC Address: $MAC_ADDRESS"

# Get IPv4 address with subnet
IPV4_ADDRESS=$(ip -4 addr show $INTERFACE | awk '/inet / {print $2}' | head -n 1)
if [ -n "$IPV4_ADDRESS" ]; then
    echo "IPv4 Address: $IPV4_ADDRESS"
    # Get IPv4 gateway
    IPV4_GATEWAY=$(ip route | awk '/default via/ && /'$INTERFACE'/ {print $3}' | head -n 1)
    echo "IPv4 Gateway: $IPV4_GATEWAY"
fi

# Get global IPv6 address with subnet
IPV6_ADDRESS=$(ip -6 addr show $INTERFACE | awk '/inet6.*scope global/ {print $2}' | head -n 1)
if [ -n "$IPV6_ADDRESS" ]; then
    echo "IPv6 Address: $IPV6_ADDRESS"
    # Get IPv6 gateway
    IPV6_GATEWAY=$(ip -6 route | awk '/default via/ && /'$INTERFACE'/ {print $3}' | head -n 1)
    echo "IPv6 Gateway: $IPV6_GATEWAY"
fi

# Check if both IPv4 and IPv6 addresses are missing
if [ -z "$IPV4_ADDRESS" ] && [ -z "$IPV6_ADDRESS" ]; then
    echo "No IP addresses found. Exiting script."
    exit 1
fi

# Generate netplan configuration
cat << EOF > $FILE_FULL_PATH
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      addresses:
EOF

# Add IPv4 and IPv6 addresses
if [ -n "$IPV4_ADDRESS" ]; then
    echo "        - $IPV4_ADDRESS" >> $FILE_FULL_PATH
fi
if [ -n "$IPV6_ADDRESS" ]; then
    echo "        - $IPV6_ADDRESS" >> $FILE_FULL_PATH
fi

# Add routes
echo "      routes:" >> $FILE_FULL_PATH
if [ -n "$IPV4_ADDRESS" ]; then
    cat << EOF >> $FILE_FULL_PATH
        - to: 0.0.0.0/0
          via: $IPV4_GATEWAY
          on-link: true
EOF
fi
if [ -n "$IPV6_ADDRESS" ]; then
    cat << EOF >> $FILE_FULL_PATH
        - to: ::/0
          via: $IPV6_GATEWAY
          on-link: true
EOF
fi

# Add common configuration
cat << EOF >> $FILE_FULL_PATH
      match:
        macaddress: $MAC_ADDRESS
      nameservers:
        addresses:
          - 2620:fe::fe
          - 1.1.1.1
EOF

echo "Netplan configuration has been generated in $FILE_FULL_PATH"
cat $FILE_FULL_PATH

chmod 0600 $FILE_FULL_PATH

install_packages

# Apply the netplan configuration
netplan apply