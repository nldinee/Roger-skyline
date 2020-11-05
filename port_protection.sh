#!/bin/bash

porg='TCP_MODE="tcp"'
prep='TCP_MODE="atcp"'
porg1='UDP_MODE="udp"'
prep1='UDP_MODE="audp"'

sed -i -e 's/'"$porg"'/'"$prep"'/g' /etc/default/portsentry
sed -i -e 's/'"$porg1"'/'"$prep1"'/g' /etc/default/portsentry

rm -rf /etc/portsentry/portsentry.conf
cp /home/nabdelba/scripts/conf/portsentry.conf /etc/portsentry/
