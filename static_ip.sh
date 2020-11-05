#!/bin/bash

IP_ADDRESS=10.11.254.42
NET_MASK=255.255.255.252
GATEWAY=10.11.254.254


echo "Setting up static ip with $IP_ADDRESS and netmask $NET_MASK"
cd /etc/network
chmod +w interfaces

org="iface enp0s3 inet dhcp"
rep="auto enp0s3"
sed -i -e 's/'"$org"'/'"$rep"'/g' /etc/network/interfaces

sed -i -e 's/'"allow-hotplug enp0s3"'/''/g' /etc/network/interfaces

cd /etc/network/interfaces.d/
touch enp0s3

echo "iface enp0s3 inet static" >> enp0s3
echo "	address ${IP_ADDRESS}" >> enp0s3
echo "	netmask ${NET_MASK}" >> enp0s3
echo "	gateway ${GATEWAY}" >> enp0s3

service networking restart
