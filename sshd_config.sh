
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
