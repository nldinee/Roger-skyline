#!/bin/bash

#install all needed packages

# Config
MAIL_NAME=debian.lan

# Colors
COLOR_INFO="\033[0;36m"
COLOR_NOTICE="\033[0;33m"
COLOR_ERR="\033[0;31m"
COLOR_RESET="\033[0m"


# functions

pr () {
	echo -e "${COLOR_INFO}${PRE_INFO}${1}${COLOR_RESET}"
}

# [+] Installing all needed packages

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

echo "postfix postfix/mailname string $MAIL_NAME" | debconf-set-selections
echo "postfix postfix/main_mailer_type string Local only" | debconf-set-selections
echo "postfix postfix/root_address string root@$(MAIL_NAME)" | debconf-set-selections
echo "postfix postfix/protocols select ipv6" | debconf-set-selections
echo "portsentry portsentry/startup_conf_obsolete note" | debconf-set-selections	
echo "portsentry portsentry/warn_no_block note" | debconf-set-selections

for p in ${pkgs[@]};
do
	pr "[+] Installing $p"
	apt-get install $p -y;
done;

# [+] Setting up staic ip


pr "Setting up static ip with $IP_ADDRESS and netmask $NET_MASK"
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
pr "[+] Restarting network"
service networking restart


