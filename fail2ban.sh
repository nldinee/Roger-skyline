#!/bin/bash

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


echo '
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*
ignoreregex =
' > /etc/fail2ban/filter.d/http-get-dos.conf

ufw reload
service fail2ban restart

