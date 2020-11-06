#!/bin/bash

#install all needed packages

# Config
SCRIPT_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}"

MAIL_NAME=debian.lan
IP_ADDRESS=10.11.254.42
NET_MASK=255.255.255.252
GATEWAY=10.11.254.254

# Colors
COLOR_INFO="\033[0;36m"
COLOR_NOTICE="\033[0;33m"
COLOR_ERR="\033[0;31m"
COLOR_RESET="\033[0m"

# functions

pr () {
	echo -e "${COLOR_INFO}${PRE_INFO}${1}${COLOR_RESET}"
}

pr_noti () {
	echo -e "${COLOR_NOTICE}${PRE_INFO}${1}${COLOR_RESET}"
}


# [+] Installing all needed packages
pr "[+] Installing all needed packages"
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
"git"
)

echo "postfix postfix/mailname string $MAIL_NAME" | debconf-set-selections
echo "postfix postfix/main_mailer_type string Local only" | debconf-set-selections
echo "postfix postfix/root_address string root@${MAIL_NAME}" | debconf-set-selections
echo "postfix postfix/protocols select ipv6" | debconf-set-selections
echo "portsentry portsentry/startup_conf_obsolete note" | debconf-set-selections	
echo "portsentry portsentry/warn_no_block note" | debconf-set-selections

for p in ${pkgs[@]};
do
	pr "[+] Installing $p"
	apt-get install $p -y;
done;

# [+] Setting up staic ip

pr "[+] Setting up static ip with $IP_ADDRESS and netmask $NET_MASK"
cd /etc/network
chmod +w interfaces

org="iface enp0s3 inet dhcp"
rep="auto enp0s3"
sed -i -e 's/'"$org"'/'"$rep"'/g' /etc/network/interfaces

sed -i -e 's/'"allow-hotplug enp0s3"'/''/g' /etc/network/interfaces

cd /etc/network/interfaces.d/
touch enp0s3

echo "iface enp0s3 inet static" > enp0s3
echo "	address ${IP_ADDRESS}" > enp0s3
echo "	netmask ${NET_MASK}" > enp0s3
echo "	gateway ${GATEWAY}" > enp0s3
pr "	- Restarting network"
service networking restart

pr "[+] Setting up sshd service"
pr_noti "[-] You should have created an copied an ssh_key on your machine to this one before disabling the password authentication"
sleep 5;
var1='#Port 22'
var2='Port 1338'
sed -i -e 's/'"$var1"'/'"$var2"'/g' /etc/ssh/sshd_config

var1='#PermitRootLogin prohibit-password'
var2='PermitRootLogin no'
sed -i -e 's/'"$var1"'/'"$var2"'/g' /etc/ssh/sshd_config

var1='#PubkeyAuthentication yes'
var2='PubkeyAuthentication yes'
sed -i -e 's/'"$var1"'/'"$var2"'/g' /etc/ssh/sshd_config

sed -i -e 's/'"#PasswordAuthentication yes"'/'"PasswordAuthentication no"'/g' /etc/ssh/sshd_config

pr "[+] Setting up firewall rules"

pr_noti "---- OPENED PORTS BEFORE SETTING RULES"
ufw status | grep "/" | awk  -F'/'  '{print "[*] "$1 ""}'
ufw enable
sleep 2


ufw allow 1338/tcp # custom ssh port
ufw allow 80/tcp # http 
ufw allow 433 # https 
ufw allow 25 # ssh 

pr_noti "---- OPENED PORTS AFTER SETTING RULES"
ufw status | grep "/" | awk  -F'/'  '{print "[*] "$1 ""}'
sleep 2

pr "[+] Setting up dos protection"

echo "
[sshd]
enabled = true
port = 1338
logpath = %(sshd_log)s
backend = %(sshd_backend)s
action = iptables[name=SSH, port=1338, protocol=tcp]
maxretry = 3
findtime = 180
bantime = 600

[http-get-dos]
enabled = true
port = http,https
filter = http-get-dos
logpath = /var/log/apache2/access.log
maxretry = 100
findtime = 180
bantime = 600
action = iptables[name=HTTP, port=http, protocol=tcp]
" > /etc/fail2ban/jail.local

pr "[+] setting up protection against port scans"

porg='TCP_MODE="tcp"'
prep='TCP_MODE="atcp"'
porg1='UDP_MODE="udp"'
prep1='UDP_MODE="audp"'

sed -i -e 's/'"$porg"'/'"$prep"'/g' /etc/default/portsentry
sed -i -e 's/'"$porg1"'/'"$prep1"'/g' /etc/default/portsentry

rm -rf /etc/portsentry/portsentry.conf
cp ${SCRIPTS_DIR}/conf/portsentry.conf /etc/portsentry/



echo '
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*
ignoreregex =
' > /etc/fail2ban/filter.d/http-get-dos.conf

ufw reload
service fail2ban restart

pr "[+] disabling unsed servcies"


sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
#to list all services:
sudo service --status-all


pr "[+] Setting up Crontab tasks"

echo "@reboot ${SCRIPTS_DIR}/update_system.sh" | crontab -
echo "0 4 * * 6 ${SCRIPTS_DIR}/update_system.sh" | crontab -
echo "0 0 * * * ${SCRIPTS_DIR}/cronMonitor.sh" | crontab -


pr "[+] Generate SSL self-signed key and certificate"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/apache-selfsigned.key \
	-out /etc/ssl/certs/apache-selfsigned.crt \
	-subj "/C=SI/ST=MA/L=RA/O=Security/OU=IT Department/CN=${IP_ADDRESS}"

if [ -f /etc/apache2/conf-available/ssl-params.conf ];
then
	cp /etc/apache2/conf-available/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf.bak;
	rm -rf /etc/apache2/conf-available/ssl-params.conf;
fi;
cp ${SCRIPTS_DIR}/conf/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf;

if [ -f /etc/apache2/conf-available/ssl-params.conf ];

if [ -f /etc/apache2/sites-available/000-default.conf];
then
	cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak;
	rm -rf /etc/apache2/sites-available/000-default.conf;
fi;
cp ${SCRIPTS_DIR}/conf/000-default.conf /etc/apache2/sites-available/000-default.conf


if [ -f /etc/apache2/sites-available/default-ssl.conf];
then
	cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak;
	rm -rf /etc/apache2/sites-available/default-ssl.conf;
fi;
cp ${SCRIPTS_DIR}/conf/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

pr "[+] Applying New apache config"

sudo a2enmod ssl
sudo a2enmod headers
sudo a2enconf ssl-params

pr "	-- Checking for sysntax errors"
apache2ctl configtest
sleep 2
pr "	-- Restatring apache service"
service apache2 restart