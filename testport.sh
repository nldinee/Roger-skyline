#!/bin/bash


por='KILL_ROUTE="/sbin/route add -host $TARGET$ reject"'
pre='KILL_ROUTE="/sbin/iptables -I INPUT -s $TARGET$ -j DROP"'

sed -i -e 's/'"$por"'/'"$pre"'/g' /etc/default/portsentry
