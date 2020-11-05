#!/bin/bash
#install all needed packages

# conf

MAIL_NAME=debian.lan

declare -a pkgs=(
"vim"
"openssh-server"
"net-tools"
"apache2"
"ufw"
"iptables"
"fail2ban"
"portsentry"
"postfix"
"mailutils"
)

for p in ${pkgs[@]};
do
	echo "[+] Installing ${p}"
	apt-get remove $p -y;
done;

rm /etc/network/interfaces.d/enp0s3

